import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/reports.dart';
import 'package:gym_tracker/domain/statistics.dart';

import '../helpers.dart';

void main() {
  final d1 = DateTime(2026, 11, 2);
  final d2 = DateTime(2026, 11, 9);
  final records = [
    record(date: d1, weightKg: 100, reps: 5),
    record(date: d1, weightKg: 105, reps: 3, setNumber: 2),
    record(date: d2, weightKg: 110, reps: 2),
    record(
      date: d2,
      weightKg: 60,
      reps: 10,
      exerciseId: 2,
      exerciseName: 'Bench',
      muscleGroup: null,
      routineName: 'Push',
    ),
  ];

  List<Object?> column(ReportTable t, ReportColumn c) => [
    for (final r in t.rows) r[t.columns.indexOf(c)],
  ];

  test('set log: one row per set, newest first by default', () {
    final t = Reports.build(
      records,
      const ReportConfig(type: ReportType.setLog),
    );
    expect(t.rows, hasLength(4));
    expect(column(t, ReportColumn.date).first, d2);
    expect(t.totals![t.columns.indexOf(ReportColumn.reps)], 20);
    expect(t.totals![t.columns.indexOf(ReportColumn.volume)], 1635);
  });

  test('by exercise: aggregates per exercise, sorted by volume', () {
    final t = Reports.build(records, const ReportConfig());
    expect(column(t, ReportColumn.exercise), ['Squat', 'Bench']);
    final squat = t.rows.first;
    int i(ReportColumn c) => t.columns.indexOf(c);
    expect(squat[i(ReportColumn.days)], 2);
    expect(squat[i(ReportColumn.sets)], 3);
    expect(squat[i(ReportColumn.volume)], 1035);
    expect(squat[i(ReportColumn.topWeight)], 110);
    expect(squat[i(ReportColumn.bestOneRepMax)], closeTo(117.33, 0.01));
    expect(t.totals![i(ReportColumn.days)], 2);
  });

  test('by period: grouping by week and sorting are configurable', () {
    final t = Reports.build(
      records,
      const ReportConfig(type: ReportType.byPeriod, grouping: Grouping.week),
    );
    expect(column(t, ReportColumn.period), [d1, d2]);
    final byVolume = Reports.build(
      records,
      const ReportConfig(
        type: ReportType.byPeriod,
        sortColumn: ReportColumn.volume,
        ascending: false,
      ),
    );
    expect(column(byVolume, ReportColumn.volume), [820, 815]);
    final monthly = Reports.build(
      records,
      const ReportConfig(type: ReportType.byPeriod, grouping: Grouping.month),
    );
    expect(monthly.rows, hasLength(1));
  });

  test('personal records keep the date the record was set', () {
    final t = Reports.build(
      records,
      const ReportConfig(type: ReportType.personalRecords),
    );
    expect(t.totals, isNull);
    final squat = t.rows.firstWhere((r) => r[0] == 'Squat');
    expect(squat[t.columns.indexOf(ReportColumn.topWeight)], 110);
    expect(squat[t.columns.indexOf(ReportColumn.topWeightDate)], d2);
    // 110 × 2 (117.3) beats 100 × 5 (116.7): the record is from d2.
    expect(squat[t.columns.indexOf(ReportColumn.bestOneRepMaxDate)], d2);
  });

  test('a sort column from another report type falls back to default', () {
    final t = Reports.build(
      records,
      const ReportConfig(
        type: ReportType.byPeriod,
        sortColumn: ReportColumn.exercise,
      ),
    );
    expect(t.sortColumn, ReportColumn.period);
  });

  test('empty values sort last in both directions', () {
    for (final ascending in [true, false]) {
      final t = Reports.build(
        records,
        ReportConfig(
          sortColumn: ReportColumn.muscleGroup,
          ascending: ascending,
        ),
      );
      expect(column(t, ReportColumn.muscleGroup).last, isNull);
      expect(column(t, ReportColumn.muscleGroup).first, MuscleGroup.legs);
    }
  });

  test('no records gives an empty table without totals errors', () {
    final t = Reports.build(const [], const ReportConfig());
    expect(t.rows, isEmpty);
    expect(t.totals![t.columns.indexOf(ReportColumn.sets)], 0);
  });
}
