import 'package:flutter/foundation.dart';

import '../../data/repositories/workout_repository.dart';
import '../../domain/progress_calculator.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';

/// The history of one exercise, one entry per training day.
class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel(this._workouts, {required this.exerciseId});

  final WorkoutRepository _workouts;
  final int exerciseId;

  ViewState<List<DailyProgress>> _state = const Loading();
  ViewState<List<DailyProgress>> get state => _state;

  Future<void> load() async {
    _state = switch (await _workouts.listSetsForExercise(exerciseId)) {
      Ok(value: final sets) when sets.isEmpty => const Empty(),
      Ok(value: final sets) => Loaded(ProgressCalculator.byDay(sets)),
      Error(:final error) => Failed(error),
    };
    notifyListeners();
  }
}
