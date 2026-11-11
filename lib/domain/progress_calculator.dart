import 'models/user_profile.dart' show dayOf;
import 'models/workout_set.dart';

/// Progress of one exercise on one training day.
class DailyProgress {
  const DailyProgress({
    required this.date,
    required this.topWeightKg,
    required this.volumeKg,
    required this.estimatedOneRepMaxKg,
    required this.setCount,
  });

  final DateTime date;

  /// Heaviest weight lifted that day.
  final double topWeightKg;

  /// Sum of weight × reps over every set that day.
  final double volumeKg;

  /// Best Epley estimate of the one-repetition maximum that day.
  final double estimatedOneRepMaxKg;

  final int setCount;
}

/// Pure calculations on logged sets. No Flutter or database imports, so it is
/// trivial to unit-test.
abstract final class ProgressCalculator {
  /// Epley estimate of the one-repetition maximum: weight × (1 + reps / 30).
  /// A single rep returns the weight itself. It is an estimate and becomes
  /// less reliable at high repetition counts.
  static double estimatedOneRepMax(double weightKg, int reps) {
    if (reps <= 1) return weightKg;
    return weightKg * (1 + reps / 30);
  }

  static double volume(Iterable<Lift> sets) =>
      sets.fold(0, (sum, s) => sum + s.weightKg * s.reps);

  /// Groups [sets] by day and returns one entry per day, oldest first.
  static List<DailyProgress> byDay(Iterable<Lift> sets) {
    final days = <DateTime, List<Lift>>{};
    for (final set in sets) {
      days.putIfAbsent(dayOf(set.date), () => []).add(set);
    }
    final result = [
      for (final MapEntry(key: day, value: daySets) in days.entries)
        DailyProgress(
          date: day,
          topWeightKg: daySets.map((s) => s.weightKg).reduce(_max),
          volumeKg: volume(daySets),
          estimatedOneRepMaxKg: daySets
              .map((s) => estimatedOneRepMax(s.weightKg, s.reps))
              .reduce(_max),
          setCount: daySets.length,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  static double _max(double a, double b) => a > b ? a : b;
}
