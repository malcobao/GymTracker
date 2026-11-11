import 'package:sqflite/sqflite.dart';

import '../../../domain/models/user_profile.dart' show dateOnly;
import '../../../domain/models/workout_set.dart';
import '../../../domain/statistics.dart';
import '../../../utils/result.dart';
import '../../errors/app_exception.dart';
import '../workout_repository.dart';
import '../../local/database_changes.dart';
import 'guard.dart';

class SqliteWorkoutRepository implements WorkoutRepository {
  SqliteWorkoutRepository(this._db, [this._changes]);

  final Database _db;
  final DatabaseChanges? _changes;

  /// READ: the sets of today's workout screen.
  @override
  Future<Result<List<WorkoutSet>>> listSetsOn(
    List<int> exerciseIds,
    DateTime day,
  ) => guard(() async {
    if (exerciseIds.isEmpty) return <WorkoutSet>[];
    final marks = List.filled(exerciseIds.length, '?').join(', ');
    final rows = await _db.query(
      'workout_sets',
      where: 'exercise_id IN ($marks) AND performed_on = ?',
      whereArgs: [...exerciseIds, dateOnly(day)],
      orderBy: 'exercise_id, set_number',
    );
    return rows.map(WorkoutSet.fromRow).toList();
  });

  /// READ: the history of one exercise.
  @override
  Future<Result<List<WorkoutSet>>> listSetsForExercise(int exerciseId) =>
      guard(() async {
        final rows = await _db.query(
          'workout_sets',
          where: 'exercise_id = ?',
          whereArgs: [exerciseId],
          orderBy: 'performed_on, set_number',
        );
        return rows.map(WorkoutSet.fromRow).toList();
      });

  /// CREATE: set number = last number of that exercise on that day + 1.
  @override
  Future<Result<WorkoutSet>> logSet({
    required int exerciseId,
    required DateTime day,
    required double weightKg,
    required int reps,
  }) => guardWrite(
    _changes,
    () => _db.transaction((txn) async {
      final rows = await txn.rawQuery(
        'SELECT COALESCE(MAX(set_number), 0) + 1 AS next FROM workout_sets '
        'WHERE exercise_id = ? AND performed_on = ?',
        [exerciseId, dateOnly(day)],
      );
      final row = {
        'exercise_id': exerciseId,
        'performed_on': dateOnly(day),
        'set_number': rows.first['next']! as int,
        'weight_kg': weightKg,
        'reps': reps,
      };
      final id = await txn.insert('workout_sets', row);
      return WorkoutSet.fromRow({...row, 'id': id});
    }),
  );

  /// UPDATE.
  @override
  Future<Result<void>> updateSet(
    int setId, {
    required double weightKg,
    required int reps,
  }) => guardWrite(_changes, () async {
    final updated = await _db.update(
      'workout_sets',
      {'weight_kg': weightKg, 'reps': reps},
      where: 'id = ?',
      whereArgs: [setId],
    );
    if (updated == 0) throw const NotFoundException();
  });

  /// DELETE, then renumber the later sets of that exercise and day so the
  /// numbers stay 1, 2, 3… (lowest first, so the UNIQUE rule never clashes).
  @override
  Future<Result<void>> deleteSet(int setId) => guardWrite(
    _changes,
    () => _db.transaction((txn) async {
      final rows = await txn.query(
        'workout_sets',
        where: 'id = ?',
        whereArgs: [setId],
      );
      if (rows.isEmpty) throw const NotFoundException();
      final deleted = WorkoutSet.fromRow(rows.first);
      await txn.delete('workout_sets', where: 'id = ?', whereArgs: [setId]);
      final later = await txn.query(
        'workout_sets',
        columns: ['id', 'set_number'],
        where: 'exercise_id = ? AND performed_on = ? AND set_number > ?',
        whereArgs: [
          deleted.exerciseId,
          dateOnly(deleted.performedOn),
          deleted.setNumber,
        ],
        orderBy: 'set_number',
      );
      for (final set in later) {
        await txn.update(
          'workout_sets',
          {'set_number': (set['set_number']! as int) - 1},
          where: 'id = ?',
          whereArgs: [set['id']],
        );
      }
    }),
  );

  /// READ: the three-table join behind statistics and reports. Every filter
  /// is a `?` parameter (never pasted into the SQL text).
  @override
  Future<Result<List<SetRecord>>> records(RecordFilter filter) =>
      guard(() async {
        final where = <String>[];
        final args = <Object?>[];
        if (filter.from case final from?) {
          where.add('s.performed_on >= ?');
          args.add(dateOnly(from));
        }
        if (filter.to case final to?) {
          where.add('s.performed_on <= ?');
          args.add(dateOnly(to));
        }
        if (filter.routineId case final id?) {
          where.add('r.id = ?');
          args.add(id);
        }
        if (filter.exerciseId case final id?) {
          where.add('e.id = ?');
          args.add(id);
        }
        if (filter.muscleGroup case final group?) {
          where.add('e.muscle_group = ?');
          args.add(group.dbValue);
        }
        final rows = await _db.rawQuery('''
          SELECT s.id AS set_id, s.performed_on, s.set_number, s.weight_kg,
                 s.reps, e.id AS exercise_id, e.name AS exercise_name,
                 e.muscle_group, r.id AS routine_id, r.name AS routine_name
            FROM workout_sets s
            JOIN exercises e ON e.id = s.exercise_id
            JOIN routines  r ON r.id = e.routine_id
           ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
           ORDER BY s.performed_on, e.position, s.set_number''', args);
        return rows.map(SetRecord.fromRow).toList();
      });
}
