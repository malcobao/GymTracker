import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/routine.dart';
import '../../utils/result.dart';

/// Values for creating or editing an exercise.
class ExerciseDraft {
  const ExerciseDraft({
    required this.name,
    this.muscleGroup,
    this.targetSets,
    this.targetReps,
  });

  final String name;
  final MuscleGroup? muscleGroup;
  final int? targetSets;
  final int? targetReps;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'muscle_group': muscleGroup?.dbValue,
    'target_sets': targetSets,
    'target_reps': targetReps,
  };
}

/// Routines and the exercises inside them. "Remove" archives instead of
/// deleting, so logged history is kept.
abstract class RoutineRepository {
  Future<Result<List<Routine>>> listRoutines();
  Future<Result<Routine>> createRoutine(String name, {String? description});
  Future<Result<void>> renameRoutine(String routineId, String name);
  Future<Result<void>> archiveRoutine(String routineId);

  /// Active exercises of a routine, ordered by position.
  Future<Result<List<Exercise>>> listExercises(String routineId);
  Future<Result<Exercise>> addExercise(String routineId, ExerciseDraft draft);
  Future<Result<void>> updateExercise(String exerciseId, ExerciseDraft draft);
  Future<Result<void>> archiveExercise(String exerciseId);

  /// Saves a new order: [exerciseIds] first to last.
  Future<Result<void>> reorderExercises(
    String routineId,
    List<String> exerciseIds,
  );
}
