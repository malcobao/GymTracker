import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/enums.dart';
import '../../utils/result.dart';
import '../core/view_models/session_controller.dart';

/// Database tools and the weight unit (stored in the `profile` table).
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this._data,
    required this._profiles,
    required this._session,
  });

  final DataRepository _data;
  final ProfileRepository _profiles;
  final SessionController _session;

  TableCounts? _counts;
  TableCounts? get counts => _counts;

  bool _busy = false;
  bool get busy => _busy;

  Future<void> loadCounts() async {
    if (await _data.counts() case Ok(:final value)) {
      _counts = value;
      notifyListeners();
    }
  }

  Future<Exception?> setUnit(WeightUnit unit) async {
    final profile = _session.profile;
    if (profile == null || profile.weightUnit == unit) return null;
    switch (await _profiles.saveProfile(profile.copyWith(weightUnit: unit))) {
      case Ok(:final value):
        _session.profileChanged(value);
        return null;
      case Error(:final error):
        return error;
    }
  }

  Future<Exception?> loadSampleData({required bool spanish}) =>
      _run(() => _data.loadSampleData(spanish: spanish));

  /// Deletes everything; the router then shows onboarding again.
  Future<Exception?> deleteAllData() async {
    final error = await _run(_data.deleteAllData);
    if (error == null) _session.profileChanged(null);
    return error;
  }

  Future<Exception?> _run(Future<Result<void>> Function() action) async {
    _busy = true;
    notifyListeners();
    final result = await action();
    _busy = false;
    await loadCounts();
    notifyListeners();
    return switch (result) {
      Ok() => null,
      Error(:final error) => error,
    };
  }
}
