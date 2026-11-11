import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/models/exercise.dart';
import 'package:gym_tracker/domain/models/user_profile.dart';
import 'package:gym_tracker/domain/models/workout_set.dart';

void main() {
  final row = {
    'id': 'u1',
    'display_name': 'Cristian',
    'birth_date': '2003-04-15',
    'sex': 'male',
    'height_cm': 178.0,
    'body_weight_kg': 75.5,
    'experience_level': 'beginner',
    'goal': 'muscle_gain',
    'weight_unit': 'kg',
    'created_at': '2026-11-11T00:00:00Z',
  };

  test('UserProfile reads a database row and writes the same values back', () {
    final profile = UserProfile.fromJson(row);
    expect(profile.goal, Goal.muscleGain);
    expect(profile.sex, Sex.male);
    final json = profile.toJson();
    for (final key in json.keys) {
      expect(json[key], row[key], reason: key);
    }
  });

  test('numeric columns may arrive as int', () {
    final profile = UserProfile.fromJson({...row, 'height_cm': 178});
    expect(profile.heightCm, 178.0);
  });

  test('ageOn counts the birthday correctly', () {
    final profile = UserProfile.fromJson(row);
    expect(profile.ageOn(DateTime(2026, 4, 14)), 22);
    expect(profile.ageOn(DateTime(2026, 4, 15)), 23);
  });

  test('dateOnly pads month and day', () {
    expect(dateOnly(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
  });

  test('WorkoutSet insert JSON uses the DATE format', () {
    final s = WorkoutSet(
      id: '',
      exerciseId: 'e1',
      performedOn: DateTime(2026, 11, 3, 18, 30),
      setNumber: 2,
      weightKg: 62.5,
      reps: 8,
    );
    expect(s.toInsertJson(), {
      'exercise_id': 'e1',
      'performed_on': '2026-11-03',
      'set_number': 2,
      'weight_kg': 62.5,
      'reps': 8,
    });
  });

  test('Exercise.targetLabel', () {
    Exercise e(int? s, int? r) => Exercise(
      id: 'e',
      routineId: 'r',
      name: 'Bench',
      position: 1,
      targetSets: s,
      targetReps: r,
    );
    expect(e(3, 8).targetLabel, '3 × 8');
    expect(e(3, null).targetLabel, '3 sets');
    expect(e(null, 8).targetLabel, '8 reps');
    expect(e(null, null).targetLabel, isNull);
  });

  test('every enum value round-trips through its database string', () {
    for (final v in MuscleGroup.values) {
      expect(MuscleGroup.fromDb(v.dbValue), v);
    }
    expect(MuscleGroup.fromDb(null), isNull);
    for (final v in Goal.values) {
      expect(Goal.fromDb(v.dbValue), v);
    }
  });
}
