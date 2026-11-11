import 'package:sqflite/sqflite.dart';

import '../../../domain/models/exercise.dart';
import '../../../domain/models/routine.dart';
import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../routine_repository.dart';
import '../../local/database_changes.dart';
import 'guard.dart';

class SqliteRoutineRepository implements RoutineRepository {
  SqliteRoutineRepository(this._db, [this._changes]);

  final Database _db;
  final DatabaseChanges? _changes;

  // ===================== routines =====================

  /// READ: routines with the number of active exercises in each.
  @override
  Future<Result<List<Routine>>> listRoutines({bool archived = false}) =>
      guard(() async {
        final rows = await _db.rawQuery('''
          SELECT r.*,
                 (SELECT COUNT(*) FROM exercises e
                   WHERE e.routine_id = r.id AND e.archived_at IS NULL)
                   AS exercise_count
            FROM routines r
           WHERE r.archived_at IS ${archived ? 'NOT ' : ''}NULL
           ORDER BY r.name COLLATE NOCASE''');
        return rows.map(Routine.fromRow).toList();
      });

  /// READ: one routine.
  @override
  Future<Result<Routine>> getRoutine(int routineId) => guard(() async {
    final rows = await _db.query(
      'routines',
      where: 'id = ?',
      whereArgs: [routineId],
    );
    if (rows.isEmpty) throw const NotFoundException();
    return Routine.fromRow(rows.first);
  });

  /// CREATE.
  @override
  Future<Result<Routine>> createRoutine(String name, {String? description}) =>
      guardWrite(_changes, () async {
        final id = await _db.insert('routines', {
          'name': name.trim(),
          'description': _blankToNull(description),
        });
        return Routine(
          id: id,
          name: name.trim(),
          description: _blankToNull(description),
        );
      });

  /// UPDATE.
  @override
  Future<Result<void>> updateRoutine(
    int routineId, {
    required String name,
    String? description,
  }) => _updateOne('routines', routineId, {
    'name': name.trim(),
    'description': _blankToNull(description),
  });

  /// Soft delete: hide, keep history.
  @override
  Future<Result<void>> archiveRoutine(int routineId) =>
      _updateOne('routines', routineId, {'archived_at': nowText()});

  /// Undo the archive. Fails with [DuplicateException] if an active routine
  /// now uses the same name (unique index).
  @override
  Future<Result<void>> restoreRoutine(int routineId) =>
      _updateOne('routines', routineId, {'archived_at': null});

  /// DELETE. Exercises go with the routine (ON DELETE CASCADE); logged sets
  /// block it (ON DELETE RESTRICT) unless [withHistory].
  @override
  Future<Result<void>> deleteRoutine(
    int routineId, {
    bool withHistory = false,
  }) => guardWrite(_changes, () async {
    try {
      await _db.transaction((txn) async {
        if (withHistory) {
          await txn.delete(
            'workout_sets',
            where: 'exercise_id IN (SELECT id FROM exercises WHERE routine_id = ?)',
            whereArgs: [routineId],
          );
        }
        final deleted = await txn.delete(
          'routines',
          where: 'id = ?',
          whereArgs: [routineId],
        );
        if (deleted == 0) throw const NotFoundException();
      });
    } on DatabaseException catch (error) {
      if (mapError(error) is! InUseException) rethrow;
      throw InUseException(
        await _countSets(
          'exercise_id IN (SELECT id FROM exercises WHERE routine_id = ?)',
          routineId,
        ),
      );
    }
  });

  // ===================== exercises =====================

  /// READ: one routine's exercises in order.
  @override
  Future<Result<List<Exercise>>> listExercises(
    int routineId, {
    bool archived = false,
  }) => guard(() async {
    final rows = await _db.query(
      'exercises',
      where: 'routine_id = ? AND archived_at IS ${archived ? 'NOT ' : ''}NULL',
      whereArgs: [routineId],
      orderBy: 'position, id',
    );
    return rows.map(Exercise.fromRow).toList();
  });

  /// READ: every exercise with its routine's name (INNER JOIN).
  @override
  Future<Result<List<Exercise>>> listAllExercises() => guard(() async {
    final rows = await _db.rawQuery('''
      SELECT e.*, r.name AS routine_name
        FROM exercises e
        JOIN routines r ON r.id = e.routine_id
       ORDER BY r.name COLLATE NOCASE, e.position''');
    return rows.map(Exercise.fromRow).toList();
  });

  /// CREATE: appended at the end of the routine.
  @override
  Future<Result<Exercise>> addExercise(int routineId, ExerciseDraft draft) =>
      guardWrite(
        _changes,
        () => _db.transaction((txn) async {
          final position = await _nextPosition(txn, routineId);
          final row = {
            ...draft.toRow(),
            'routine_id': routineId,
            'position': position,
          };
          final id = await txn.insert('exercises', row);
          return Exercise.fromRow({...row, 'id': id});
        }),
      );

  /// UPDATE.
  @override
  Future<Result<void>> updateExercise(int exerciseId, ExerciseDraft draft) =>
      _updateOne('exercises', exerciseId, draft.toRow());

  @override
  Future<Result<void>> archiveExercise(int exerciseId) =>
      _updateOne('exercises', exerciseId, {'archived_at': nowText()});

  /// Restores to the end of the routine.
  @override
  Future<Result<void>> restoreExercise(int exerciseId) => guardWrite(
    _changes,
    () => _db.transaction((txn) async {
      final rows = await txn.query(
        'exercises',
        columns: ['routine_id'],
        where: 'id = ?',
        whereArgs: [exerciseId],
      );
      if (rows.isEmpty) throw const NotFoundException();
      final position = await _nextPosition(
        txn,
        rows.first['routine_id']! as int,
      );
      await txn.update(
        'exercises',
        {'archived_at': null, 'position': position, 'updated_at': nowText()},
        where: 'id = ?',
        whereArgs: [exerciseId],
      );
    }),
  );

  /// DELETE. Blocked by ON DELETE RESTRICT while sets exist, unless
  /// [withHistory].
  @override
  Future<Result<void>> deleteExercise(
    int exerciseId, {
    bool withHistory = false,
  }) => guardWrite(_changes, () async {
    try {
      await _db.transaction((txn) async {
        if (withHistory) {
          await txn.delete(
            'workout_sets',
            where: 'exercise_id = ?',
            whereArgs: [exerciseId],
          );
        }
        final deleted = await txn.delete(
          'exercises',
          where: 'id = ?',
          whereArgs: [exerciseId],
        );
        if (deleted == 0) throw const NotFoundException();
      });
    } on DatabaseException catch (error) {
      if (mapError(error) is! InUseException) rethrow;
      throw InUseException(await _countSets('exercise_id = ?', exerciseId));
    }
  });

  /// UPDATE positions 1..n in one transaction.
  @override
  Future<Result<void>> reorderExercises(int routineId, List<int> exerciseIds) =>
      guardWrite(
        _changes,
        () => _db.transaction((txn) async {
          for (var i = 0; i < exerciseIds.length; i++) {
            await txn.update(
              'exercises',
              {'position': i + 1},
              where: 'id = ? AND routine_id = ?',
              whereArgs: [exerciseIds[i], routineId],
            );
          }
        }),
      );

  // ===================== helpers =====================

  Future<Result<void>> _updateOne(
    String table,
    int id,
    Map<String, Object?> values,
  ) => guardWrite(_changes, () async {
    final updated = await _db.update(
      table,
      {...values, 'updated_at': nowText()},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updated == 0) throw const NotFoundException();
  });

  Future<int> _nextPosition(DatabaseExecutor db, int routineId) async {
    final rows = await db.rawQuery(
      'SELECT COALESCE(MAX(position), 0) + 1 AS next FROM exercises '
      'WHERE routine_id = ? AND archived_at IS NULL',
      [routineId],
    );
    return rows.first['next']! as int;
  }

  Future<int> _countSets(String where, int id) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS n FROM workout_sets WHERE $where',
      [id],
    );
    return rows.first['n']! as int;
  }

  static String? _blankToNull(String? text) =>
      (text == null || text.trim().isEmpty) ? null : text.trim();
}
