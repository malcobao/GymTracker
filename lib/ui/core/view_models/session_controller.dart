import 'package:flutter/foundation.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';

enum SessionStatus { loading, needsOnboarding, ready, error }

/// Knows whether the profile exists (personal app: no accounts or login).
/// The router listens to it: no profile → onboarding, profile → the app.
class SessionController extends ChangeNotifier {
  SessionController(this._profiles);

  final ProfileRepository _profiles;

  SessionStatus _status = SessionStatus.loading;
  SessionStatus get status => _status;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  /// The unit every weight is shown in.
  WeightUnit get unit => _profile?.weightUnit ?? WeightUnit.kg;

  Future<void> load() async {
    _status = SessionStatus.loading;
    notifyListeners();
    switch (await _profiles.getProfile()) {
      case Ok(value: final profile):
        _profile = profile;
        _status = profile == null
            ? SessionStatus.needsOnboarding
            : SessionStatus.ready;
      case Error():
        _status = SessionStatus.error;
    }
    notifyListeners();
  }

  /// Called after the profile was saved (or after all data was deleted).
  void profileChanged(UserProfile? profile) {
    _profile = profile;
    _status = profile == null
        ? SessionStatus.needsOnboarding
        : SessionStatus.ready;
    notifyListeners();
  }
}
