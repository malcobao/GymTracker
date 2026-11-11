import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';
import '../../utils/user_message.dart';
import '../../utils/result.dart';

enum AuthMode { signIn, signUp }

class SignInViewModel extends ChangeNotifier {
  SignInViewModel(this._auth);

  final AuthRepository _auth;

  AuthMode _mode = AuthMode.signIn;
  AuthMode get mode => _mode;

  bool _busy = false;
  bool get busy => _busy;

  String? _error;
  String? get error => _error;

  /// Information such as "check your email"; not an error.
  String? _info;
  String? get info => _info;

  void toggleMode() {
    _mode = _mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
    _error = null;
    _info = null;
    notifyListeners();
  }

  /// Signs in or signs up, depending on [mode]. On success the router moves
  /// on by itself because the auth state changes.
  Future<void> submit(String email, String password) async {
    _busy = true;
    _error = null;
    _info = null;
    notifyListeners();

    if (_mode == AuthMode.signIn) {
      if (await _auth.signIn(email, password) case Error(:final error)) {
        _error = userMessage(error);
      }
    } else {
      switch (await _auth.signUp(email, password)) {
        case Ok(value: SignUpOutcome.confirmationEmailSent):
          _info =
              'Account created. Open the confirmation link we emailed you, '
              'then sign in.';
          _mode = AuthMode.signIn;
        case Ok(value: SignUpOutcome.signedIn):
          break;
        case Error(:final error):
          _error = userMessage(error);
      }
    }
    _busy = false;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    _busy = true;
    _error = null;
    _info = null;
    notifyListeners();
    switch (await _auth.sendPasswordReset(email)) {
      case Ok():
        _info = 'If that email has an account, a reset link is on its way.';
      case Error(:final error):
        _error = userMessage(error);
    }
    _busy = false;
    notifyListeners();
  }
}
