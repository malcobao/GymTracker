import 'models/enums.dart';
import 'models/user_profile.dart' show dayOf;
import 'models/workout_set.dart';
import 'progress_calculator.dart';

/// Which logged sets a statistic or report looks at. Every field is optional;
/// the repository turns the filter into a parameterised SQL `WHERE`.
class RecordFilter {
  const RecordFilter({
    this.from,
    this.to,
    this.routineId,
    this.exerciseId,
    this.muscleGroup,
  });

  /// First day included (inclusive). Null = since the beginning.
  final DateTime? from;

  /// Last day included (inclusive). Null = until today.
  final DateTime? to;
  final int? routineId;
  final int? exerciseId;
  final MuscleGroup? muscleGroup;

  RecordFilter copyWith({
    DateTime? Function()? from,
    DateTime? Function()? to,
    int? Function()? routineId,
    int? Function()? exerciseId,
    MuscleGroup? Function()? muscleGroup,
  }) => RecordFilter(
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    routineId: routineId == null ? this.routineId : routineId(),
    exerciseId: exerciseId == null ? this.exerciseId : exerciseId(),
    muscleGroup: muscleGroup == null ? this.muscleGroup : muscleGroup(),
  );
}

/// How dates are grouped in time series and period reports.
enum Grouping { day, week, month }

/// What is measured.
enum Metric { volume, sets, reps }

/// The headline numbers of the statistics screen.
class StatsSummary {
  const StatsSummary({
    required this.trainingDays,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolumeKg,
    required this.averageVolumePerDayKg,
    required this.averageSetsPerDay,
    required this.bestOneRepMaxKg,
    required this.bestOneRepMaxExercise,
    required this.currentStreakWeeks,
  });

  final int trainingDays;
  final int totalSets;
  final int totalReps;
  final double totalVolumeKg;
  final double averageVolumePerDayKg;
  final double averageSetsPerDay;
  final double bestOneRepMaxKg;
  final String? bestOneRepMaxExercise;

  /// Consecutive weeks (Monday to Sunday), up to this week, with at least one
  /// training day. The current week counts only once it has a session, but a
  /// week without one yet does not break the streak.
  final int currentStreakWeeks;
}

/// One point of a time series: the period starting on [start] and its value.
typedef SeriesPoint = ({DateTime start, double value});

/// One ranked exercise: its name and its value.
typedef RankedItem = ({String name, double value});

/// Pure statistics over logged sets. No Flutter or database code, so every
/// number on the statistics screen is covered by unit tests.
abstract final class Statistics {
  static StatsSummary summary(List<SetRecord> records, {DateTime? today}) {
    final days = {for (final r in records) dayOf(r.date)};
    final volume = ProgressCalculator.volume(records);
    var best = 0.0;
    String? bestName;
    for (final r in records) {
      final e1rm = ProgressCalculator.estimatedOneRepMax(r.weightKg, r.reps);
      if (e1rm > best) {
        best = e1rm;
        bestName = r.exerciseName;
      }
    }
    return StatsSummary(
      trainingDays: days.length,
      totalSets: records.length,
      totalReps: records.fold(0, (sum, r) => sum + r.reps),
      totalVolumeKg: volume,
      averageVolumePerDayKg: days.isEmpty ? 0 : volume / days.length,
      averageSetsPerDay: days.isEmpty ? 0 : records.length / days.length,
      bestOneRepMaxKg: best,
      bestOneRepMaxExercise: bestName,
      currentStreakWeeks: weekStreak(days, today ?? DateTime.now()),
    );
  }

  /// See [StatsSummary.currentStreakWeeks].
  static int weekStreak(Set<DateTime> trainingDays, DateTime today) {
    final weeks = {for (final d in trainingDays) periodStart(d, Grouping.week)};
    var week = periodStart(today, Grouping.week);
    if (!weeks.contains(week)) week = _addDays(week, -7);
    var streak = 0;
    while (weeks.contains(week)) {
      streak++;
      week = _addDays(week, -7);
    }
    return streak;
  }

  /// Start of the day, week (Monday) or month that contains [date].
  static DateTime periodStart(DateTime date, Grouping grouping) =>
      switch (grouping) {
        Grouping.day => dayOf(date),
        Grouping.week => _addDays(dayOf(date), -(date.weekday - 1)),
        Grouping.month => DateTime(date.year, date.month),
      };

  static double metricOf(Iterable<SetRecord> records, Metric metric) =>
      switch (metric) {
        Metric.volume => ProgressCalculator.volume(records),
        Metric.sets => records.length.toDouble(),
        Metric.reps => records.fold(0, (sum, r) => sum + r.reps),
      };

  /// [metric] per day, week or month, oldest first. Periods without training
  /// between the first and the last one are included with value 0, so the
  /// chart shows the gaps.
  static List<SeriesPoint> timeSeries(
    List<SetRecord> records, {
    required Metric metric,
    required Grouping grouping,
  }) {
    if (records.isEmpty) return const [];
    final buckets = <DateTime, List<SetRecord>>{};
    for (final r in records) {
      buckets.putIfAbsent(periodStart(r.date, grouping), () => []).add(r);
    }
    final starts = buckets.keys.toList()..sort();
    final result = <SeriesPoint>[];
    for (var p = starts.first; !p.isAfter(starts.last); p = next(p, grouping)) {
      final bucket = buckets[p];
      result.add((
        start: p,
        value: bucket == null ? 0 : metricOf(bucket, metric),
      ));
    }
    return result;
  }

  /// The period after the one starting on [start].
  static DateTime next(DateTime start, Grouping grouping) => switch (grouping) {
    Grouping.day => _addDays(start, 1),
    Grouping.week => _addDays(start, 7),
    Grouping.month => DateTime(start.year, start.month + 1),
  };

  /// [metric] per muscle group, largest first. Exercises without a muscle
  /// group are counted under `null`.
  static List<({MuscleGroup? group, double value})> byMuscleGroup(
    List<SetRecord> records, {
    required Metric metric,
  }) {
    final groups = <MuscleGroup?, List<SetRecord>>{};
    for (final r in records) {
      groups.putIfAbsent(r.muscleGroup, () => []).add(r);
    }
    return [
      for (final MapEntry(:key, :value) in groups.entries)
        (group: key, value: metricOf(value, metric)),
    ]..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Training days per weekday: index 0 = Monday … 6 = Sunday.
  static List<int> trainingDaysByWeekday(List<SetRecord> records) {
    final counts = List.filled(7, 0);
    for (final day in {for (final r in records) dayOf(r.date)}) {
      counts[day.weekday - 1]++;
    }
    return counts;
  }

  /// The [limit] exercises with the highest [metric], highest first.
  /// [byOneRepMax] ranks by best estimated 1RM instead of [metric].
  static List<RankedItem> topExercises(
    List<SetRecord> records, {
    Metric metric = Metric.volume,
    bool byOneRepMax = false,
    int limit = 5,
  }) {
    final byExercise = <int, List<SetRecord>>{};
    for (final r in records) {
      byExercise.putIfAbsent(r.exerciseId, () => []).add(r);
    }
    final ranked = [
      for (final sets in byExercise.values)
        (
          name: sets.first.exerciseName,
          value: byOneRepMax
              ? sets
                    .map(
                      (s) => ProgressCalculator.estimatedOneRepMax(
                        s.weightKg,
                        s.reps,
                      ),
                    )
                    .reduce((a, b) => a > b ? a : b)
              : metricOf(sets, metric),
        ),
    ]..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(limit).toList();
  }

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);
}
