import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('PostgreSQL codes map to user-facing errors', () {
    expect(
      mapError(
        const PostgrestException(message: 'dup', code: '23505'),
        duplicateMessage: 'Name taken',
      ),
      isA<DuplicateException>().having(
        (e) => e.message,
        'message',
        'Name taken',
      ),
    );
    expect(
      mapError(const PostgrestException(message: 'check', code: '23514')),
      isA<InvalidDataException>(),
    );
    expect(
      mapError(const PostgrestException(message: 'rls', code: '42501')),
      isA<PermissionException>(),
    );
  });

  test('network problems become NetworkException', () {
    expect(mapError(const SocketException('offline')), isA<NetworkException>());
    expect(
      mapError(AuthRetryableFetchException(message: 'offline')),
      isA<NetworkException>(),
    );
  });

  test('auth error codes get friendly messages', () {
    expect(
      mapError(const AuthException('x', code: 'invalid_credentials')).message,
      'Wrong email or password.',
    );
    expect(
      mapError(const AuthException('x', code: 'email_not_confirmed')).message,
      startsWith('Confirm your email'),
    );
  });

  test('anything else is UnknownException', () {
    expect(mapError(StateError('?')), isA<UnknownException>());
  });
}
