import 'package:sqflite/sqflite.dart';

import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';
import '../profile_repository.dart';
import '../../local/database_changes.dart';
import 'guard.dart';

class SqliteProfileRepository implements ProfileRepository {
  SqliteProfileRepository(this._db, [this._changes]);

  final Database _db;
  final DatabaseChanges? _changes;

  /// READ: `SELECT * FROM profile WHERE id = 1`.
  @override
  Future<Result<UserProfile?>> getProfile() => guard(() async {
    final rows = await _db.query(
      'profile',
      where: 'id = ?',
      whereArgs: [UserProfile.singletonId],
    );
    return rows.isEmpty ? null : UserProfile.fromRow(rows.first);
  });

  /// CREATE the first time, UPDATE afterwards, in one transaction.
  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) =>
      guardWrite(_changes, () async {
        await _db.transaction((txn) async {
          final row = profile.toRow();
          final updated = await txn.update(
            'profile',
            {...row, 'updated_at': nowText()}..remove('id'),
            where: 'id = ?',
            whereArgs: [UserProfile.singletonId],
          );
          if (updated == 0) await txn.insert('profile', row);
        });
        return profile;
      });
}
