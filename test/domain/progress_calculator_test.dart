import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/workout_set.dart';
import 'package:gym_tracker/domain/progress_calculator.dart';

WorkoutSet set(String day, int n, double kg, int reps) => WorkoutSet(
  id: '$day-$n',
  exerciseId: 'bench',
  performedOn: DateTime.parse(day),
  setNumber: n,
  weightKg: kg,
  reps: reps,
);

void main() {
  group('estimatedOneRepMax (Epley)', () {
    test('60 kg × 8 = 76 kg', () {
      expect(ProgressCalculator.estimatedOneRepMax(60, 8), closeTo(76.0, 1e-9));
    });

    test('a single rep is the weight itself', () {
      expect(ProgressCalculator.estimatedOneRepMax(100, 1), 100);
    });
  });

  test(
    'byDay groups by date, oldest first, with the worked-example numbers',
    () {
      // Same data as the design doc's worked example.
      final days = ProgressCalculator.byDay([
        set('2026-10-27', 1, 62.5, 8),
        set('2026-10-20', 1, 60, 8),
        set('2026-10-20', 2, 60, 8),
        set('2026-10-20', 3, 60, 7),
        set('2026-10-27', 2, 62.5, 8),
        set('2026-10-27', 3, 62.5, 6),
      ]);

      expect(days, hasLength(2));
      expect(days[0].date, DateTime(2026, 10, 20));
      expect(days[0].topWeightKg, 60);
      expect(days[0].volumeKg, 1380);
      expect(days[0].estimatedOneRepMaxKg, closeTo(76.0, 1e-9));
      expect(days[0].setCount, 3);

      expect(days[1].date, DateTime(2026, 10, 27));
      expect(days[1].topWeightKg, 62.5);
      expect(days[1].volumeKg, 1375);
      expect(days[1].estimatedOneRepMaxKg, closeTo(79.1667, 1e-4));
    },
  );

  test('byDay of no sets is empty', () {
    expect(ProgressCalculator.byDay([]), isEmpty);
  });
}
