import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../domain/models/routine.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

/// State and actions of the routine list (CRUD of the `routines` table).
/// Every action returns null on success or the error to show.
class RoutineListViewModel extends ChangeNotifier {
  RoutineListViewModel(this._routines);

  final RoutineRepository _routines;

  ViewState<List<Routine>> _state = const Loading();
  ViewState<List<Routine>> get state => _state;

  bool _showArchived = false;
  bool get showArchived => _showArchived;

  /// Names of active routines: a new or renamed routine may not reuse one
  /// (checked while typing, and again by the database's unique index).
  List<String> _activeNames = const [];
  List<String> get activeNames => _activeNames;

  Future<void> load() async {
    if (_state is! Loaded) {
      _state = const Loading();
      notifyListeners();
    }
    final active = await _routines.listRoutines();
    final shown = _showArchived
        ? await _routines.listRoutines(archived: true)
        : active;
    if (active case Ok(value: final list)) {
      _activeNames = [for (final r in list) r.name];
    }
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

  Future<Exception?> create(String name, String? description) =>
      _run(_routines.createRoutine(name, description: description));

  Future<Exception?> update(int id, String name, String? description) =>
      _run(_routines.updateRoutine(id, name: name, description: description));

  Future<Exception?> archive(int id) => _run(_routines.archiveRoutine(id));

  Future<Exception?> restore(int id) => _run(_routines.restoreRoutine(id));

  Future<Exception?> delete(int id, {bool withHistory = false}) =>
      _run(_routines.deleteRoutine(id, withHistory: withHistory));

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
