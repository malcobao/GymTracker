import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/routine.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

/// State and actions of one routine's exercises (CRUD of `exercises`).
class RoutineDetailViewModel extends ChangeNotifier {
  RoutineDetailViewModel(this._routines, {required this.routineId});

  final RoutineRepository _routines;
  final int routineId;

  Routine? _routine;
  Routine? get routine => _routine;

  ViewState<List<Exercise>> _state = const Loading();
  ViewState<List<Exercise>> get state => _state;

  bool _showArchived = false;
  bool get showArchived => _showArchived;

  List<String> _activeNames = const [];

  /// Active exercise names: a new one may not reuse them.
  List<String> get activeNames => _activeNames;

  List<Exercise> get exercises => switch (_state) {
    Loaded(:final data) => data,
    _ => const [],
  };

  Future<void> load() async {
    if (_state is! Loaded) {
      _state = const Loading();
      notifyListeners();
    }
    if (await _routines.getRoutine(routineId) case Ok(:final value)) {
      _routine = value;
    }
    final active = await _routines.listExercises(routineId);
    if (active case Ok(value: final list)) {
      _activeNames = [for (final e in list) e.name];
    }
    final shown = _showArchived
        ? await _routines.listExercises(routineId, archived: true)
        : active;
    _state = switch (shown) {
      Ok(value: final list) when list.isEmpty => const Empty(),
      Ok(value: final list) => Loaded(list),
      Error(:final error) => Failed(error),
    };
    notifyListeners();
  }

  Future<void> toggleArchived() {
    _showArchived = !_showArchived;
    _state = const Loading();
    notifyListeners();
    return load();
  }

  Future<Exception?> add(ExerciseDraft draft) =>
      _run(_routines.addExercise(routineId, draft));

  Future<Exception?> update(int id, ExerciseDraft draft) =>
      _run(_routines.updateExercise(id, draft));

  Future<Exception?> archive(int id) => _run(_routines.archiveExercise(id));

  Future<Exception?> restore(int id) => _run(_routines.restoreExercise(id));

  Future<Exception?> delete(int id, {bool withHistory = false}) =>
      _run(_routines.deleteExercise(id, withHistory: withHistory));

  /// Moves an exercise as reported by `ReorderableListView.onReorderItem`.
  /// The new order shows at once and is saved in the background; on failure
  /// the saved order is reloaded.
  Future<Exception?> move(int oldIndex, int newIndex) async {
    final list = [...exercises];
    list.insert(newIndex, list.removeAt(oldIndex));
    _state = Loaded(list);
    notifyListeners();
    switch (await _routines.reorderExercises(routineId, [
      for (final e in list) e.id,
    ])) {
      case Ok():
        return null;
      case Error(:final error):
        await load();
        return error;
    }
  }

  Future<Exception?> _run(Future<Result<Object?>> action) async {
    switch (await action) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return error;
    }
  }
}
