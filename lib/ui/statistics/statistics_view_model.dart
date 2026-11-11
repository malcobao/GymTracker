import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/progress_calculator.dart';
import '../../domain/statistics.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';
import '../core/widgets/filters.dart';

/// Parameters and results of the statistics screen. Changing a filter
/// reloads the sets from the database; changing a chart parameter only
/// recalculates (the [Statistics] functions are pure and fast).
class StatisticsViewModel extends ChangeNotifier {
  StatisticsViewModel({
    required this._routines,
    required this._workouts,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RoutineRepository _routines;
  final WorkoutRepository _workouts;
  final DateTime Function() _clock;

  ViewState<List<SetRecord>> _state = const Loading();
  ViewState<List<SetRecord>> get state => _state;
  List<SetRecord> get records => switch (_state) {
    Loaded(:final data) => data,
    _ => const [],
  };

  Lookups _lookups = const Lookups();
  Lookups get lookups => _lookups;

  // ---- global filters (parameters of every statistic) ----
  FilterSelection _selection = const FilterSelection();
  FilterSelection get selection => _selection;

  // ---- per-chart parameters ----
  Metric _seriesMetric = Metric.volume;
  Metric get seriesMetric => _seriesMetric;
  Grouping _grouping = Grouping.week;
  Grouping get grouping => _grouping;
  Metric _muscleMetric = Metric.sets;
  Metric get muscleMetric => _muscleMetric;
  bool _rankByOneRepMax = false;
  bool get rankByOneRepMax => _rankByOneRepMax;
  int _topN = 5;
  int get topN => _topN;
  int? _oneRepMaxExerciseId;

  Future<void> load() async {
    if (_state is! Loaded) {
      _state = const Loading();
      notifyListeners();
    }
    _lookups = await Lookups.load(_routines);
    final result = await _workouts.records(_selection.toFilter(_clock()));
    _state = switch (result) {
      Ok(value: final list) when list.isEmpty => const Empty(),
      Ok(value: final list) => Loaded(list),
      Error(:final error) => Failed(error),
    };
    notifyListeners();
  }

  void setSelection(FilterSelection value) {
    _selection = value;
    load();
  }

  void setSeriesMetric(Metric value) => _set(() => _seriesMetric = value);
  void setGrouping(Grouping value) => _set(() => _grouping = value);
  void setMuscleMetric(Metric value) => _set(() => _muscleMetric = value);
  void setRankByOneRepMax(bool value) => _set(() => _rankByOneRepMax = value);
  void setTopN(int value) => _set(() => _topN = value);
  void setOneRepMaxExercise(int value) =>
      _set(() => _oneRepMaxExerciseId = value);

  void _set(void Function() change) {
    change();
    notifyListeners();
  }

  // ---- results (each one is one statistic of the screen) ----

  StatsSummary get summary => Statistics.summary(records, today: _clock());

  List<SeriesPoint> get series => Statistics.timeSeries(
    records,
    metric: _seriesMetric,
    grouping: _grouping,
  );

  List<({String name, int id})> get exercisesInData {
    final seen = <int, String>{};
    for (final r in records) {
      seen.putIfAbsent(r.exerciseId, () => r.exerciseName);
    }
    return [for (final e in seen.entries) (id: e.key, name: e.value)];
  }

  /// The exercise of the 1RM chart: the chosen one if it has data in the
  /// selection, otherwise the one with most sets.
  int? get oneRepMaxExerciseId {
    final ids = exercisesInData.map((e) => e.id).toSet();
    if (ids.contains(_oneRepMaxExerciseId)) return _oneRepMaxExerciseId;
    final top = Statistics.topExercises(records, metric: Metric.sets, limit: 1);
    if (top.isEmpty) return null;
    return records
        .firstWhere((r) => r.exerciseName == top.first.name)
        .exerciseId;
  }

  List<DailyProgress> get oneRepMaxProgress {
    final id = oneRepMaxExerciseId;
    return ProgressCalculator.byDay(records.where((r) => r.exerciseId == id));
  }

  List<({MuscleGroup? group, double value})> get byMuscleGroup =>
      Statistics.byMuscleGroup(records, metric: _muscleMetric);

  List<int> get byWeekday => Statistics.trainingDaysByWeekday(records);

  List<RankedItem> get topExercises => Statistics.topExercises(
    records,
    byOneRepMax: _rankByOneRepMax,
    limit: _topN,
  );
}
