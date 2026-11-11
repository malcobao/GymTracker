import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../utils/result.dart';
import '../core/view_models/session_controller.dart';

/// Saves the profile (CREATE on onboarding, UPDATE afterwards).
class ProfileFormViewModel extends ChangeNotifier {
  ProfileFormViewModel({required this._profiles, required this._session});

  final ProfileRepository _profiles;
  final SessionController _session;

  UserProfile? get existing => _session.profile;

  bool _saving = false;
  bool get saving => _saving;

  /// Returns null on success or the error to show.
  Future<Exception?> save(UserProfile profile) async {
    _saving = true;
    notifyListeners();
    final result = await _profiles.saveProfile(profile);
    _saving = false;
    notifyListeners();
    switch (result) {
      case Ok(:final value):
        _session.profileChanged(value);
        return null;
      case Error(:final error):
        return error;
    }
  }
}
