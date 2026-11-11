import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/user_profile.dart';
import '../../../utils/user_message.dart';
import '../../../utils/result.dart';

enum SessionStatus {
  /// Checking whether a profile exists.
  loading,
  signedOut,

  /// Signed in, but the onboarding profile has not been created yet.
  needsOnboarding,
  ready,

  /// Signed in, but the profile could not be loaded (for example, offline).
  error,
}

/// App-wide state: who is signed in and their profile. The router listens to
/// it to decide which screen may be shown.
class SessionController extends ChangeNotifier {
  SessionController({required this._auth, required this._profiles}) {
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SessionStatus _status = SessionStatus.loading;
  SessionStatus get status => _status;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool? _wasSignedIn;

  void _onAuthChanged() {
    final signedIn = _auth.isSignedIn;
    if (signedIn == _wasSignedIn) return;
    _wasSignedIn = signedIn;
    if (signedIn) {
      reload();
    } else {
      _profile = null;
      _set(SessionStatus.signedOut);
    }
  }

  /// Loads the profile again, for example after an error.
  Future<void> reload() async {
    _set(SessionStatus.loading);
    switch (await _profiles.getMyProfile()) {
      case Ok(value: final profile?):
        _profile = profile;
        _set(SessionStatus.ready);
      case Ok(value: null):
        _set(SessionStatus.needsOnboarding);
      case Error(:final error):
        _errorMessage = userMessage(error);
        _set(SessionStatus.error);
    }
  }

  /// Called after the profile form saves successfully.
  void profileSaved(UserProfile profile) {
    _profile = profile;
    _set(SessionStatus.ready);
  }

  Future<void> signOut() => _auth.signOut();

  void _set(SessionStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
