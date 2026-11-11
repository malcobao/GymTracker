import 'package:flutter/foundation.dart';

import '../../utils/result.dart';

/// What happened after a sign-up request.
enum SignUpOutcome {
  /// The account exists and the user is signed in.
  signedIn,

  /// The account was created; the user must confirm their email first.
  confirmationEmailSent,
}

/// Accounts and sessions. Notifies listeners whenever the user signs in or out,
/// which the router uses to redirect.
abstract class AuthRepository extends ChangeNotifier {
  bool get isSignedIn;

  /// Id of the signed-in user, equal to `users.id` in the database.
  String? get userId;

  Future<Result<SignUpOutcome>> signUp(String email, String password);
  Future<Result<void>> signIn(String email, String password);
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordReset(String email);
}
