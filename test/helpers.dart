import 'package:gym_tracker/data/local/app_database.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/models/user_profile.dart';
import 'package:gym_tracker/domain/models/workout_set.dart';
import 'package:gym_tracker/utils/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A fresh, empty, in-memory SQLite database with the app's real schema.
/// The "no isolate" factory runs SQLite in the test's own isolate, so it also
/// works inside widget tests (fake async). Close it in tearDown.
Future<Database> openTestDatabase() {
  sqfliteFfiInit();
  return AppDatabase.open(databaseFactoryFfiNoIsolate, inMemoryDatabasePath);
}

UserProfile sampleProfile({WeightUnit unit = WeightUnit.kg}) => UserProfile(
  displayName: 'Cristian',
  birthDate: DateTime(2003, 4, 15),
  sex: Sex.male,
  heightCm: 178,
  bodyWeightKg: 75.5,
  experienceLevel: ExperienceLevel.beginner,
  goal: Goal.muscleGain,
  weightUnit: unit,
);

/// The value of an `Ok`, or a test failure.
T ok<T>(Result<T> result) => switch (result) {
  Ok(:final value) => value,
  Error(:final error) => throw StateError('Expected Ok, got $error'),
};

/// The error of an `Error`, or a test failure.
Exception err<T>(Result<T> result) => switch (result) {
  Ok(:final value) => throw StateError('Expected Error, got Ok($value)'),
  Error(:final error) => error,
};

/// A joined set record for the pure calculation tests.
SetRecord record({
  required DateTime date,
  double weightKg = 100,
  int reps = 5,
  int exerciseId = 1,
  String exerciseName = 'Squat',
  MuscleGroup? muscleGroup = MuscleGroup.legs,
  int routineId = 1,
  String routineName = 'Legs',
  int setNumber = 1,
  int setId = 0,
}) => SetRecord(
  setId: setId,
  date: date,
  setNumber: setNumber,
  weightKg: weightKg,
  reps: reps,
  exerciseId: exerciseId,
  exerciseName: exerciseName,
  muscleGroup: muscleGroup,
  routineId: routineId,
  routineName: routineName,
);
