import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Every failure the UI can show. Repositories convert library exceptions into
/// one of these, so screens never depend on Supabase types.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// A message that can be shown to the user as is.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException()
    : super('No internet connection. Nothing was saved; please try again.');
}

final class DuplicateException extends AppException {
  const DuplicateException([super.message = 'That name is already in use.']);
}

final class InvalidDataException extends AppException {
  const InvalidDataException([
    super.message = 'Some values are out of the allowed range.',
  ]);
}

final class PermissionException extends AppException {
  const PermissionException()
    : super("You don't have permission to do that. Try signing in again.");
}

final class AuthFailedException extends AppException {
  const AuthFailedException(super.message);
}

final class NotSignedInException extends AppException {
  const NotSignedInException() : super('Please sign in first.');
}

final class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

/// Maps any error thrown by Supabase or the network to an [AppException].
///
/// PostgreSQL codes: 23505 unique violation, 23514 check violation,
/// 23503 foreign key violation, 42501 insufficient privilege (RLS).
AppException mapError(Object error, {String? duplicateMessage}) {
  return switch (error) {
    AppException() => error,
    SocketException() || TimeoutException() => const NetworkException(),
    AuthRetryableFetchException() => const NetworkException(),
    PostgrestException(code: '23505') => DuplicateException(
      duplicateMessage ?? 'That name is already in use.',
    ),
    PostgrestException(code: '23514') => const InvalidDataException(),
    PostgrestException(code: '23503') => const InvalidDataException(
      'That item no longer exists. Refresh and try again.',
    ),
    PostgrestException(code: '42501') => const PermissionException(),
    AuthException(:final code, :final message) => AuthFailedException(
      _authMessage(code, message),
    ),
    _ => const UnknownException(),
  };
}

String _authMessage(String? code, String fallback) => switch (code) {
  'invalid_credentials' => 'Wrong email or password.',
  'email_not_confirmed' =>
    'Confirm your email first: open the link we sent you, then sign in.',
  'user_already_exists' || 'email_exists' =>
    'An account with this email already exists. Sign in instead.',
  'weak_password' => 'That password is too weak. Use a longer one.',
  'over_email_send_rate_limit' || 'over_request_rate_limit' =>
    'Too many attempts. Wait a minute and try again.',
  _ => fallback,
};
