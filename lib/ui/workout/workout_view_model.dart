import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout_set.dart';
import '../../utils/user_message.dart';
import '../../utils/result.dart';
import '../../utils/units.dart';
import '../core/view_models/view_state.dart';

/// One exercise and the sets logged for it today.
class ExerciseWithSets {
  const ExerciseWithSets(this.exercise, this.sets);
  final Exercise exercise;
  final List<WorkoutSet> sets;
}

/// Logging today's sets for every exercise of one routine.
class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel({
    required this._routines,
    required this._workouts,
    required this.routineId,
    required this.unit,
    DateTime? day,
  }) : day = _dateOf(day ?? DateTime.now());

  final RoutineRepository _routines;
  final WorkoutRepository _workouts;
  final String routineId;

  /// The unit the user types weights in; stored values are always kg.
  final WeightUnit unit;

  /// The training day (local date, no time).
  final DateTime day;

  ViewState<List<ExerciseWithSets>> _state = const Loading();
  ViewState<List<ExerciseWithSets>> get state => _state;

  /// The loaded exercises, or an empty list in any other state.
  @visibleForTesting
  List<ExerciseWithSets> get exercisesForTest => switch (_state) {
    Loaded(:final data) => data,
    _ => const [],
  };

  bool _saving = false;
  bool get saving => _saving;

  static DateTime _dateOf(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final exercisesResult = await _routines.listExercises(routineId);
    if (exercisesResult case Error(:final error)) {
      _state = Failed(userMessage(error));
      notifyListeners();
      return;
    }
    final exercises = (exercisesResult as Ok<List<Exercise>>).value;
    if (exercises.isEmpty) {
      _state = const Empty();
      notifyListeners();
      return;
    }
    final setsResult = await _workouts.listSetsOn([
      for (final e in exercises) e.id,
    ], day);
    _state = switch (setsResult) {
      Ok(value: final sets) => Loaded([
        for (final e in exercises)
          ExerciseWithSets(e, [
            for (final s in sets)
              if (s.exerciseId == e.id) s,
          ]),
      ]),
      Error(:final error) => Failed(userMessage(error)),
    };
    notifyListeners();
  }

  /// [weight] is in [unit]. Returns an error message, or null on success.
  Future<String?> logSet(String exerciseId, double weight, int reps) async {
    _saving = true;
    notifyListeners();
    final result = await _workouts.logSet(
      exerciseId: exerciseId,
      day: day,
      weightKg: double.parse(Units.toKg(weight, unit).toStringAsFixed(2)),
      reps: reps,
    );
    _saving = false;
    switch (result) {
      case Ok(value: final saved):
        _replaceSets(exerciseId, (sets) => [...sets, saved]);
        return null;
      case Error(:final error):
        notifyListeners();
        return userMessage(error);
    }
  }

  Future<String?> deleteSet(WorkoutSet set) async {
    switch (await _workouts.deleteSet(set.id)) {
      case Ok():
        _replaceSets(
          set.exerciseId,
          (sets) => [
            for (final s in sets)
              if (s.id != set.id) s,
          ],
        );
        return null;
      case Error(:final error):
        return userMessage(error);
    }
  }

  void _replaceSets(
    String exerciseId,
    List<WorkoutSet> Function(List<WorkoutSet>) change,
  ) {
    if (_state case Loaded(data: final items)) {
      _state = Loaded([
        for (final item in items)
          item.exercise.id == exerciseId
              ? ExerciseWithSets(item.exercise, change(item.sets))
              : item,
      ]);
    }
    notifyListeners();
  }
}
