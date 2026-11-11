import 'models/user_profile.dart' show dayOf;
import 'models/workout_set.dart';
import 'progress_calculator.dart';
import 'statistics.dart';

/// The four kinds of report the user can build.
enum ReportType {
  /// Every logged set, one row each.
  setLog,

  /// One row per exercise: days, sets, reps, volume, best lifts.
  byExercise,

  /// One row per day, week or month.
  byPeriod,

  /// Best weight and best estimated 1RM per exercise, with their dates.
  personalRecords,
}

/// Every column a report can have.
enum ReportColumn {
  date(ColumnKind.date),
  period(ColumnKind.date),
  routine(ColumnKind.text),
  exercise(ColumnKind.text),
  muscleGroup(ColumnKind.muscleGroup),
  setNumber(ColumnKind.integer),
  weight(ColumnKind.weight),
  reps(ColumnKind.integer),
  volume(ColumnKind.weight),
  sets(ColumnKind.integer),
  days(ColumnKind.integer),
  topWeight(ColumnKind.weight),
  topWeightDate(ColumnKind.date),
  bestOneRepMax(ColumnKind.weight),
  bestOneRepMaxDate(ColumnKind.date);

  const ReportColumn(this.kind);
  final ColumnKind kind;

  bool get isNumeric => kind == ColumnKind.integer || kind == ColumnKind.weight;
}

/// How a column's values are typed (and therefore formatted and sorted).
/// Weights are always kilograms here; the UI converts to the user's unit.
enum ColumnKind { date, text, integer, weight, muscleGroup }

/// Everything the user chose on the reports screen.
class ReportConfig {
  const ReportConfig({
    this.type = ReportType.byExercise,
    this.filter = const RecordFilter(),
    this.grouping = Grouping.week,
    this.sortColumn,
    this.ascending = false,
  });

  final ReportType type;
  final RecordFilter filter;

  /// Used by [ReportType.byPeriod].
  final Grouping grouping;

  /// Null = the report type's default order.
  final ReportColumn? sortColumn;
  final bool ascending;

  ReportConfig copyWith({
    ReportType? type,
    RecordFilter? filter,
    Grouping? grouping,
    ReportColumn? Function()? sortColumn,
    bool? ascending,
  }) => ReportConfig(
    type: type ?? this.type,
    filter: filter ?? this.filter,
    grouping: grouping ?? this.grouping,
    sortColumn: sortColumn == null ? this.sortColumn : sortColumn(),
    ascending: ascending ?? this.ascending,
  );
}

/// A finished report: typed cells, ready to show as a table or export as CSV.
class ReportTable {
  const ReportTable({
    required this.columns,
    required this.rows,
    required this.sortColumn,
    required this.ascending,
    this.totals,
  });

  final List<ReportColumn> columns;
  final List<List<Object?>> rows;

  /// Sum (or count) per column; null cells have no total.
  final List<Object?>? totals;
  final ReportColumn sortColumn;
  final bool ascending;
}

/// Builds reports from logged sets. Pure Dart: covered by unit tests.
abstract final class Reports {
  static List<ReportColumn> columnsOf(ReportType type) => switch (type) {
    ReportType.setLog => const [
      ReportColumn.date,
      ReportColumn.routine,
      ReportColumn.exercise,
      ReportColumn.muscleGroup,
      ReportColumn.setNumber,
      ReportColumn.weight,
      ReportColumn.reps,
      ReportColumn.volume,
    ],
    ReportType.byExercise => const [
      ReportColumn.exercise,
      ReportColumn.routine,
      ReportColumn.muscleGroup,
      ReportColumn.days,
      ReportColumn.sets,
      ReportColumn.reps,
      ReportColumn.volume,
      ReportColumn.topWeight,
      ReportColumn.bestOneRepMax,
    ],
    ReportType.byPeriod => const [
      ReportColumn.period,
      ReportColumn.days,
      ReportColumn.sets,
      ReportColumn.reps,
      ReportColumn.volume,
      ReportColumn.topWeight,
    ],
    ReportType.personalRecords => const [
      ReportColumn.exercise,
      ReportColumn.muscleGroup,
      ReportColumn.topWeight,
      ReportColumn.topWeightDate,
      ReportColumn.bestOneRepMax,
      ReportColumn.bestOneRepMaxDate,
    ],
  };

  static (ReportColumn, bool) defaultSort(ReportType type) => switch (type) {
    ReportType.setLog => (ReportColumn.date, false),
    ReportType.byExercise => (ReportColumn.volume, false),
    ReportType.byPeriod => (ReportColumn.period, true),
    ReportType.personalRecords => (ReportColumn.bestOneRepMax, false),
  };

  static ReportTable build(List<SetRecord> records, ReportConfig config) {
    final columns = columnsOf(config.type);
    final (defaultColumn, defaultAscending) = defaultSort(config.type);
    final useConfigured =
        config.sortColumn != null && columns.contains(config.sortColumn);
    final sortColumn = useConfigured ? config.sortColumn! : defaultColumn;
    final ascending = useConfigured ? config.ascending : defaultAscending;

    final rows = switch (config.type) {
      ReportType.setLog => _setLog(records),
      ReportType.byExercise => _byExercise(records),
      ReportType.byPeriod => _byPeriod(records, config.grouping),
      ReportType.personalRecords => _personalRecords(records),
    };
    final index = columns.indexOf(sortColumn);
    rows.sort((a, b) {
      final (x, y) = (a[index], b[index]);
      if (x == null || y == null) return _compare(x, y); // nulls always last
      final order = _compare(x, y);
      return ascending ? order : -order;
    });

    return ReportTable(
      columns: columns,
      rows: rows,
      sortColumn: sortColumn,
      ascending: ascending,
      totals: config.type == ReportType.personalRecords
          ? null
          : _totals(columns, records),
    );
  }

  static List<List<Object?>> _setLog(List<SetRecord> records) => [
    for (final r in records)
      [
        dayOf(r.date),
        r.routineName,
        r.exerciseName,
        r.muscleGroup,
        r.setNumber,
        r.weightKg,
        r.reps,
        r.volumeKg,
      ],
  ];

  static List<List<Object?>> _byExercise(List<SetRecord> records) => [
    for (final sets in _groupBy(records, (r) => r.exerciseId).values)
      [
        sets.first.exerciseName,
        sets.first.routineName,
        sets.first.muscleGroup,
        {for (final s in sets) dayOf(s.date)}.length,
        sets.length,
        sets.fold<int>(0, (sum, s) => sum + s.reps),
        ProgressCalculator.volume(sets),
        _maxOf(sets.map((s) => s.weightKg)),
        _maxOf(sets.map(_e1rm)),
      ],
  ];

  static List<List<Object?>> _byPeriod(
    List<SetRecord> records,
    Grouping grouping,
  ) => [
    for (final MapEntry(key: start, value: sets) in _groupBy(
      records,
      (r) => Statistics.periodStart(r.date, grouping),
    ).entries)
      [
        start,
        {for (final s in sets) dayOf(s.date)}.length,
        sets.length,
        sets.fold<int>(0, (sum, s) => sum + s.reps),
        ProgressCalculator.volume(sets),
        _maxOf(sets.map((s) => s.weightKg)),
      ],
  ];

  static List<List<Object?>> _personalRecords(List<SetRecord> records) => [
    for (final sets in _groupBy(records, (r) => r.exerciseId).values)
      () {
        // Earliest date wins a tie: that is when the record was set.
        final byDate = [...sets]..sort((a, b) => a.date.compareTo(b.date));
        var heaviest = byDate.first;
        var strongest = byDate.first;
        for (final s in byDate) {
          if (s.weightKg > heaviest.weightKg) heaviest = s;
          if (_e1rm(s) > _e1rm(strongest)) strongest = s;
        }
        return <Object?>[
          sets.first.exerciseName,
          sets.first.muscleGroup,
          heaviest.weightKg,
          dayOf(heaviest.date),
          _e1rm(strongest),
          dayOf(strongest.date),
        ];
      }(),
  ];

  static List<Object?> _totals(
    List<ReportColumn> columns,
    List<SetRecord> records,
  ) => [
    for (final column in columns)
      switch (column) {
        ReportColumn.days => {for (final r in records) dayOf(r.date)}.length,
        ReportColumn.sets => records.length,
        ReportColumn.reps => records.fold<int>(0, (sum, r) => sum + r.reps),
        ReportColumn.volume => ProgressCalculator.volume(records),
        ReportColumn.topWeight when records.isNotEmpty => _maxOf(
          records.map((r) => r.weightKg),
        ),
        _ => null,
      },
  ];

  static double _e1rm(SetRecord r) =>
      ProgressCalculator.estimatedOneRepMax(r.weightKg, r.reps);

  static double _maxOf(Iterable<double> values) =>
      values.reduce((a, b) => a > b ? a : b);

  static Map<K, List<SetRecord>> _groupBy<K>(
    List<SetRecord> records,
    K Function(SetRecord) key,
  ) {
    final groups = <K, List<SetRecord>>{};
    for (final r in records) {
      groups.putIfAbsent(key(r), () => []).add(r);
    }
    return groups;
  }

  /// Nulls sort last; numbers, dates and text in their natural order.
  static int _compare(Object? a, Object? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return switch ((a, b)) {
      (final num x, final num y) => x.compareTo(y),
      (final DateTime x, final DateTime y) => x.compareTo(y),
      (final Enum x, final Enum y) => x.index.compareTo(y.index),
      _ => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()),
    };
  }
}
