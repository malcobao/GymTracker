import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../domain/models/exercise.dart';
import '../../utils/user_message.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

class RoutineDetailViewModel extends ChangeNotifier {
  RoutineDetailViewModel(this._routines, {required this.routineId});

  final RoutineRepository _routines;
  final String routineId;

  ViewState<List<Exercise>> _state = const Loading();
  ViewState<List<Exercise>> get state => _state;

  List<Exercise> get exercises => switch (_state) {
    Loaded(:final data) => data,
    _ => const [],
  };

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    _state = switch (await _routines.listExercises(routineId)) {
      Ok(value: final list) when list.isEmpty => const Empty(),
      Ok(value: final list) => Loaded(list),
      Error(:final error) => Failed(userMessage(error)),
    };
    notifyListeners();
  }

  Future<String?> add(ExerciseDraft draft) async {
    switch (await _routines.addExercise(routineId, draft)) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }

  Future<String?> update(String exerciseId, ExerciseDraft draft) async {
    switch (await _routines.updateExercise(exerciseId, draft)) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }

  Future<String?> archive(String exerciseId) async {
    switch (await _routines.archiveExercise(exerciseId)) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }

  /// Moves an exercise as reported by [ReorderableListView.onReorderItem]
  /// (where [newIndex] is already adjusted for the removed item). The new
  /// order is shown at once and saved in the background; on failure the list
  /// is reloaded from the server.
  Future<String?> move(int oldIndex, int newIndex) async {
    final list = [...exercises];
    list.insert(newIndex, list.removeAt(oldIndex));
    _state = Loaded(list);
    notifyListeners();
    final ids = [for (final e in list) e.id];
    switch (await _routines.reorderExercises(routineId, ids)) {
      case Ok():
        return null;
      case Error(:final error):
        await load();
        return userMessage(error);
    }
  }
}
