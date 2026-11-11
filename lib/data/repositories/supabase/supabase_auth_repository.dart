import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../auth_repository.dart';

class SupabaseAuthRepository extends AuthRepository {
  SupabaseAuthRepository(this._auth) {
    _subscription = _auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final GoTrueClient _auth;
  late final StreamSubscription<AuthState> _subscription;

  @override
  bool get isSignedIn => _auth.currentSession != null;

  @override
  String? get userId => _auth.currentUser?.id;

  @override
  Future<Result<SignUpOutcome>> signUp(String email, String password) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      return Result.ok(
        response.session == null
            ? SignUpOutcome.confirmationEmailSent
            : SignUpOutcome.signedIn,
      );
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<void>> signIn(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email.trim(), password: password);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
      return const Result.ok(null);
    } catch (e) {
      return Result.error(mapError(e));
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
