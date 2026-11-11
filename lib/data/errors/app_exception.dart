import 'package:sqflite/sqflite.dart' show DatabaseException;

/// Every failure the UI can show. Repositories convert database exceptions
/// into one of these, so screens never depend on SQLite types. The UI shows a
/// translated message for each type (`ui/core/labels.dart`).
sealed class AppException implements Exception {
  const AppException();

  @override
  String toString() => runtimeType.toString();
}

/// A UNIQUE constraint failed, e.g. two active routines with the same name.
final class DuplicateException extends AppException {
  const DuplicateException();
}

/// A CHECK or NOT NULL constraint failed: a value is out of range.
final class InvalidDataException extends AppException {
  const InvalidDataException();
}

/// A FOREIGN KEY constraint (ON DELETE RESTRICT) blocked a delete because
/// logged sets still point to the row.
final class InUseException extends AppException {
  const InUseException(this.setCount);

  /// How many logged sets depend on the row.
  final int setCount;
}

/// The row does not exist (any more).
final class NotFoundException extends AppException {
  const NotFoundException();
}

/// Anything else (disk full, corrupted file, ...).
final class StorageException extends AppException {
  const StorageException([this.cause]);
  final Object? cause;

  @override
  String toString() => 'StorageException: $cause';
}

/// Maps any error thrown by SQLite to an [AppException].
AppException mapError(Object error) {
  if (error is AppException) return error;
  if (error is DatabaseException) {
    final message = error.toString();
    if (error.isUniqueConstraintError()) return const DuplicateException();
    if (message.contains('FOREIGN KEY constraint failed')) {
      return const InUseException(0);
    }
    if (message.contains('CHECK constraint failed') ||
        error.isNotNullConstraintError()) {
      return const InvalidDataException();
    }
  }
  return StorageException(error);
}
