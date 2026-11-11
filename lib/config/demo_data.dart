import '../data/repositories/routine_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../domain/models/enums.dart';
import '../domain/models/exercise.dart';
import '../domain/models/routine.dart';
import '../utils/result.dart';

/// Sample data for demo mode: one routine with two past bench-press sessions,
/// so the progress screen has something to show straight away.
Future<void> seedDemoData(
  RoutineRepository routines,
  WorkoutRepository workouts, {
  DateTime? today,
}) async {
  final now = today ?? DateTime.now();
  final routine = await routines.createRoutine(
    'Push day',
    description: 'Chest, shoulders and triceps',
  );
  if (routine is! Ok<Routine>) return;
  final pushDay = routine.value;

  final bench = await routines.addExercise(
    pushDay.id,
    const ExerciseDraft(
      name: 'Bench press',
      muscleGroup: MuscleGroup.chest,
      targetSets: 3,
      targetReps: 8,
    ),
  );
  await routines.addExercise(
    pushDay.id,
    const ExerciseDraft(
      name: 'Overhead press',
      muscleGroup: MuscleGroup.shoulders,
      targetSets: 3,
      targetReps: 10,
    ),
  );
  await routines.addExercise(
    pushDay.id,
    const ExerciseDraft(name: 'Dips', muscleGroup: MuscleGroup.triceps),
  );
  if (bench is! Ok<Exercise>) return;
  final benchPress = bench.value;

  // Same numbers as the design doc's worked example.
  final sessions = {
    14: [(60.0, 8), (60.0, 8), (60.0, 7)],
    7: [(62.5, 8), (62.5, 8), (62.5, 6)],
  };
  for (final MapEntry(key: daysAgo, value: sets) in sessions.entries) {
    final day = DateTime(now.year, now.month, now.day - daysAgo);
    for (final (kg, reps) in sets) {
      await workouts.logSet(
        exerciseId: benchPress.id,
        day: day,
        weightKg: kg,
        reps: reps,
      );
    }
  }
}
