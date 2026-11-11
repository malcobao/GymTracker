import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/workout_set.dart';
import '../../domain/reports.dart';
import '../../domain/statistics.dart';
import '../../utils/result.dart';
import '../core/view_models/view_state.dart';
import '../core/widgets/filters.dart';

/// The configurable report: type, filters, grouping and sort order.
class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required this._routines,
    required this._workouts,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RoutineRepository _routines;
  final WorkoutRepository _workouts;
  final DateTime Function() _clock;

  ViewState<List<SetRecord>> _state = const Loading();
  ViewState<List<SetRecord>> get state => _state;

  Lookups _lookups = const Lookups();
  Lookups get lookups => _lookups;

  FilterSelection _selection = const FilterSelection(
    preset: PeriodPreset.last30Days,
  );
  FilterSelection get selection => _selection;

  ReportConfig _config = const ReportConfig();
  ReportConfig get config => _config;

  /// The report for the current configuration (recalculated on demand).
  ReportTable get table => Reports.build(switch (_state) {
    Loaded(:final data) => data,
    _ => const <SetRecord>[],
  }, _config);

  Future<void> load() async {
    if (_state is! Loaded) {
      _state = const Loading();
      notifyListeners();
    }
    _lookups = await Lookups.load(_routines);
    final filter = _selection.toFilter(_clock());
    _config = _config.copyWith(filter: filter);
    _state = switch (await _workouts.records(filter)) {
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

  void setType(ReportType type) {
    // Each report type starts in its own natural order.
    _config = _config.copyWith(type: type, sortColumn: () => null);
    notifyListeners();
  }

  void setGrouping(Grouping grouping) {
    _config = _config.copyWith(grouping: grouping);
    notifyListeners();
  }

  void sortBy(ReportColumn column, {bool? ascending}) {
    final current = table;
    _config = _config.copyWith(
      sortColumn: () => column,
      ascending:
          ascending ??
          (current.sortColumn == column
              ? !current.ascending
              : !column.isNumeric),
    );
    notifyListeners();
  }
}
