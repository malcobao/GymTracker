import '../../domain/models/workout_set.dart';
import '../../utils/result.dart';

/// Logged sets.
abstract class WorkoutRepository {
  /// Sets of the given exercises on one day, ordered by set number.
  Future<Result<List<WorkoutSet>>> listSetsOn(
    List<String> exerciseIds,
    DateTime day,
  );

  /// Every set of one exercise, oldest first.
  Future<Result<List<WorkoutSet>>> listSetsForExercise(String exerciseId);

  /// Logs the next set of [exerciseId] on [day]; the set number is assigned
  /// automatically.
  Future<Result<WorkoutSet>> logSet({
    required String exerciseId,
    required DateTime day,
    required double weightKg,
    required int reps,
  });

  Future<Result<void>> deleteSet(String setId);
}
