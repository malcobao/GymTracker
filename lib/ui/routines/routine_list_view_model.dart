import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../domain/models/routine.dart';
import '../../utils/user_message.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

class RoutineListViewModel extends ChangeNotifier {
  RoutineListViewModel(this._routines);

  final RoutineRepository _routines;

  ViewState<List<Routine>> _state = const Loading();
  ViewState<List<Routine>> get state => _state;

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    _state = switch (await _routines.listRoutines()) {
      Ok(value: final list) when list.isEmpty => const Empty(),
      Ok(value: final list) => Loaded(list),
      Error(:final error) => Failed(userMessage(error)),
    };
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> create(String name, String? description) async {
    switch (await _routines.createRoutine(name, description: description)) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }

  Future<String?> rename(String routineId, String name) async {
    switch (await _routines.renameRoutine(routineId, name)) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }

  Future<String?> archive(String routineId) async {
    switch (await _routines.archiveRoutine(routineId)) {
      case Ok():
        await load();
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }
}
