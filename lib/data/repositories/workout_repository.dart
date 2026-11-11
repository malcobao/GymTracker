import '../../domain/models/workout_set.dart';
import '../../domain/statistics.dart';
import '../../utils/result.dart';

/// CRUD of the `workout_sets` table, plus the joined query that statistics
/// and reports are built from.
abstract class WorkoutRepository {
  /// Sets of the given exercises on one day, ordered by set number.
  Future<Result<List<WorkoutSet>>> listSetsOn(
    List<int> exerciseIds,
    DateTime day,
  );

  /// Every set of one exercise, oldest first.
  Future<Result<List<WorkoutSet>>> listSetsForExercise(int exerciseId);

  /// Create: logs the next set of [exerciseId] on [day]; the set number is
  /// assigned automatically.
  Future<Result<WorkoutSet>> logSet({
    required int exerciseId,
    required DateTime day,
    required double weightKg,
    required int reps,
  });

  /// Update: corrects the weight and reps of a logged set.
  Future<Result<void>> updateSet(
    int setId, {
    required double weightKg,
    required int reps,
  });

  /// Delete: removes a set and renumbers the later sets of that day.
  Future<Result<void>> deleteSet(int setId);

  /// Logged sets joined with their exercise and routine, filtered by
  /// [filter], oldest first.
  Future<Result<List<SetRecord>>> records(RecordFilter filter);
}

/// Row counts of the four tables, shown in Settings.
typedef TableCounts = ({int profile, int routines, int exercises, int sets});

/// Whole-database operations.
abstract class DataRepository {
  Future<Result<TableCounts>> counts();

  /// Inserts three routines and about eight weeks of logged sets, so the
  /// statistics and reports have something to show. [spanish] picks the
  /// language of the routine and exercise names.
  Future<Result<void>> loadSampleData({required bool spanish, DateTime? today});

  /// Deletes every row of the four tables (in an order that respects the
  /// foreign keys).
  Future<Result<void>> deleteAllData();
}
