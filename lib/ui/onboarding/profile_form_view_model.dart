import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../utils/user_message.dart';
import '../../utils/result.dart';
import '../core/view_models/session_controller.dart';

/// Shared by first-time onboarding and "Edit profile".
class ProfileFormViewModel extends ChangeNotifier {
  ProfileFormViewModel({
    required this._profiles,
    required this._session,
    required this.userId,
  });

  final ProfileRepository _profiles;
  final SessionController _session;
  final String userId;

  /// The current profile when editing; null during onboarding.
  UserProfile? get existing => _session.profile;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  /// Returns true when saved.
  Future<bool> save(UserProfile profile) async {
    _saving = true;
    _error = null;
    notifyListeners();
    final result = await _profiles.saveProfile(profile);
    _saving = false;
    switch (result) {
      case Ok(value: final saved):
        _session.profileSaved(saved);
        notifyListeners();
        return true;
      case Error(:final error):
        _error = userMessage(error);
        notifyListeners();
        return false;
    }
  }
}
