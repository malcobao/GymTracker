import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../../local/database_changes.dart';

/// Runs [action] and turns any thrown error into `Result.error(AppException)`,
/// so callers never see a raw SQLite exception.
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Result.ok(await action());
  } on Object catch (error) {
    return Result.error(mapError(error));
  }
}

/// Like [guard] for INSERT/UPDATE/DELETE: tells [changes] when it worked.
Future<Result<T>> guardWrite<T>(
  DatabaseChanges? changes,
  Future<T> Function() action,
) async {
  final result = await guard(action);
  if (result is Ok) changes?.changed();
  return result;
}

/// Current time as SQLite's `datetime('now')` text (UTC).
String nowText() => DateTime.now()
    .toUtc()
    .toIso8601String()
    .replaceFirst('T', ' ')
    .substring(0, 19);
