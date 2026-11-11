import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/routine.dart';
import '../../domain/models/user_profile.dart' show dayOf;
import '../../domain/models/workout_set.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

/// One exercise of today's workout and the sets already logged for it.
typedef WorkoutItem = ({Exercise exercise, List<WorkoutSet> sets});

/// Today's workout of one routine (CRUD of `workout_sets`). Weights are
/// always kilograms here; the screen converts from the user's unit.
class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel({
    required this._routines,
    required this._workouts,
    required this.routineId,
    DateTime? day,
  }) : day = dayOf(day ?? DateTime.now());

  final RoutineRepository _routines;
  final WorkoutRepository _workouts;
  final int routineId;
  final DateTime day;

  Routine? _routine;
  Routine? get routine => _routine;

  ViewState<List<WorkoutItem>> _state = const Loading();
  ViewState<List<WorkoutItem>> get state => _state;

  bool _saving = false;
  bool get saving => _saving;

  Future<void> load() async {
    if (await _routines.getRoutine(routineId) case Ok(:final value)) {
      _routine = value;
    }
    final exercises = await _routines.listExercises(routineId);
    if (exercises case Error(:final error)) {
      _state = Failed(error);
      notifyListeners();
      return;
    }
    final list = (exercises as Ok<List<Exercise>>).value;
    if (list.isEmpty) {
      _state = const Empty();
      notifyListeners();
      return;
    }
    final sets = await _workouts.listSetsOn([for (final e in list) e.id], day);
    _state = switch (sets) {
      Ok(value: final all) => Loaded([
        for (final e in list)
          (
            exercise: e,
            sets: [
              for (final s in all)
                if (s.exerciseId == e.id) s,
            ],
          ),
      ]),
      Error(:final error) => Failed(error),
    };
    notifyListeners();
  }

  /// CREATE a set. Returns the logged set or the error.
  Future<Result<WorkoutSet>> logSet(
    int exerciseId,
    double weightKg,
    int reps,
  ) => _busy(
    () => _workouts.logSet(
      exerciseId: exerciseId,
      day: day,
      weightKg: weightKg,
      reps: reps,
    ),
  );

  /// UPDATE a set.
  Future<Result<void>> updateSet(int setId, double weightKg, int reps) =>
      _busy(() => _workouts.updateSet(setId, weightKg: weightKg, reps: reps));

  /// DELETE a set (later sets are renumbered by the repository).
  Future<Result<void>> deleteSet(int setId) =>
      _busy(() => _workouts.deleteSet(setId));

  Future<Result<T>> _busy<T>(Future<Result<T>> Function() action) async {
    _saving = true;
    notifyListeners();
    final result = await action();
    _saving = false;
    if (result is Ok) {
      await load();
    } else {
      notifyListeners();
    }
    return result;
  }
}
