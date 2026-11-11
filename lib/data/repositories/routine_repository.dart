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

  Map<String, Object?> toRow() => {
    'name': name.trim(),
    'muscle_group': muscleGroup?.dbValue,
    'target_sets': targetSets,
    'target_reps': targetReps,
  };
}

/// CRUD of the `routines` and `exercises` tables.
///
/// Removing has two levels:
/// * archive: hides the row, keeps its history (can be restored);
/// * delete: removes the row for good. If logged sets depend on it the
///   database refuses (FOREIGN KEY ... ON DELETE RESTRICT) and the call
///   returns [InUseException] with the number of sets, unless
///   `withHistory` is true, which deletes those sets first.
abstract class RoutineRepository {
  // ---- routines ----
  Future<Result<List<Routine>>> listRoutines({bool archived = false});
  Future<Result<Routine>> getRoutine(int routineId);
  Future<Result<Routine>> createRoutine(String name, {String? description});
  Future<Result<void>> updateRoutine(
    int routineId, {
    required String name,
    String? description,
  });
  Future<Result<void>> archiveRoutine(int routineId);
  Future<Result<void>> restoreRoutine(int routineId);
  Future<Result<void>> deleteRoutine(int routineId, {bool withHistory = false});

  // ---- exercises ----
  /// Exercises of a routine ordered by position.
  Future<Result<List<Exercise>>> listExercises(
    int routineId, {
    bool archived = false,
  });

  /// Every exercise (active and archived) with its routine name; used by
  /// the statistics and report filters.
  Future<Result<List<Exercise>>> listAllExercises();
  Future<Result<Exercise>> addExercise(int routineId, ExerciseDraft draft);
  Future<Result<void>> updateExercise(int exerciseId, ExerciseDraft draft);
  Future<Result<void>> archiveExercise(int exerciseId);
  Future<Result<void>> restoreExercise(int exerciseId);
  Future<Result<void>> deleteExercise(
    int exerciseId, {
    bool withHistory = false,
  });

  /// Saves a new order: [exerciseIds] first to last.
  Future<Result<void>> reorderExercises(int routineId, List<int> exerciseIds);
}
