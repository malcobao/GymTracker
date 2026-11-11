import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/statistics.dart';

import '../helpers.dart';

void main() {
  // 2026-11-02 is a Monday.
  final mon = DateTime(2026, 11, 2);
  final wed = DateTime(2026, 11, 4);
  final nextMon = DateTime(2026, 11, 9);

  final records = [
    record(date: mon, weightKg: 100, reps: 5), // squat, legs: 500
    record(date: mon, weightKg: 100, reps: 5, setNumber: 2), // 500
    record(
      date: wed,
      weightKg: 60,
      reps: 10, // 1RM 80
      exerciseId: 2,
      exerciseName: 'Bench',
      muscleGroup: MuscleGroup.chest,
    ), // 600
    record(
      date: nextMon,
      weightKg: 120,
      reps: 3, // 1RM 132
      exerciseId: 1,
    ), // 360
  ];

  group('summary', () {
    final s = Statistics.summary(records, today: DateTime(2026, 11, 10));

    test('counts days, sets, reps and volume', () {
      expect(s.trainingDays, 3);
      expect(s.totalSets, 4);
      expect(s.totalReps, 23);
      expect(s.totalVolumeKg, 1960);
    });

    test('averages per training day', () {
      expect(s.averageVolumePerDayKg, closeTo(653.33, 0.01));
      expect(s.averageSetsPerDay, closeTo(1.33, 0.01));
    });

    test('best estimated 1RM and its exercise', () {
      expect(s.bestOneRepMaxKg, closeTo(132, 1e-9));
      expect(s.bestOneRepMaxExercise, 'Squat');
    });

    test('empty input gives zeros, not NaN', () {
      final e = Statistics.summary(const [], today: mon);
      expect(e.averageVolumePerDayKg, 0);
      expect(e.bestOneRepMaxExercise, isNull);
    });
  });

  group('week streak', () {
    test('counts consecutive weeks up to this week', () {
      expect(Statistics.weekStreak({mon, nextMon}, DateTime(2026, 11, 10)), 2);
    });

    test('a week without sessions yet does not break it', () {
      expect(Statistics.weekStreak({mon}, DateTime(2026, 11, 12)), 1);
    });

    test('a missed full week breaks it', () {
      expect(Statistics.weekStreak({mon}, DateTime(2026, 11, 18)), 0);
    });
  });

  group('time series', () {
    test('weekly volume with Monday as week start', () {
      final s = Statistics.timeSeries(
        records,
        metric: Metric.volume,
        grouping: Grouping.week,
      );
      expect(s.map((p) => p.start), [mon, nextMon]);
      expect(s.map((p) => p.value), [1600, 360]);
    });

    test('daily series fills the gaps with zero', () {
      final s = Statistics.timeSeries(
        records,
        metric: Metric.sets,
        grouping: Grouping.day,
      );
      expect(s, hasLength(8)); // Nov 2 … Nov 9
      expect(s.map((p) => p.value), [2, 0, 1, 0, 0, 0, 0, 1]);
    });

    test('monthly reps', () {
      final s = Statistics.timeSeries(
        records,
        metric: Metric.reps,
        grouping: Grouping.month,
      );
      expect(s.single.start, DateTime(2026, 11));
      expect(s.single.value, 23);
    });

    test('period start of a Sunday is the Monday before', () {
      expect(Statistics.periodStart(DateTime(2026, 11, 8), Grouping.week), mon);
    });
  });

  test('distribution by muscle group, largest first', () {
    final d = Statistics.byMuscleGroup(records, metric: Metric.volume);
    expect(d.map((e) => e.group), [MuscleGroup.legs, MuscleGroup.chest]);
    expect(d.map((e) => e.value), [1360, 600]);
  });

  test('training days per weekday (Monday first)', () {
    expect(Statistics.trainingDaysByWeekday(records), [2, 0, 1, 0, 0, 0, 0]);
  });

  group('top exercises', () {
    test('by volume', () {
      final top = Statistics.topExercises(records);
      expect(top.map((t) => t.name), ['Squat', 'Bench']);
      expect(top.first.value, 1360);
    });

    test('by best estimated 1RM, limited', () {
      final top = Statistics.topExercises(records, byOneRepMax: true, limit: 1);
      expect(top.single.name, 'Squat');
      expect(top.single.value, closeTo(132, 1e-9));
    });
  });
}
