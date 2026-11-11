import 'package:flutter/foundation.dart';

import '../../data/repositories/workout_repository.dart';
import '../../domain/progress_calculator.dart';
import '../../utils/user_message.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel(this._workouts, {required this.exerciseId});

  final WorkoutRepository _workouts;
  final String exerciseId;

  /// One entry per training day, oldest first.
  ViewState<List<DailyProgress>> _state = const Loading();
  ViewState<List<DailyProgress>> get state => _state;

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    _state = switch (await _workouts.listSetsForExercise(exerciseId)) {
      Ok(value: final sets) when sets.isEmpty => const Empty(),
      Ok(value: final sets) => Loaded(ProgressCalculator.byDay(sets)),
      Error(:final error) => Failed(userMessage(error)),
    };
    notifyListeners();
  }
}
