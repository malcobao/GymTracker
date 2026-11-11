import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../../domain/models/enums.dart';
import '../../../domain/models/user_profile.dart' show dateOnly, dayOf;
import '../../../utils/result.dart';
import '../workout_repository.dart';
import '../../local/database_changes.dart';
import 'guard.dart';

class SqliteDataRepository implements DataRepository {
  SqliteDataRepository(this._db, [this._changes]);

  final Database _db;
  final DatabaseChanges? _changes;

  @override
  Future<Result<TableCounts>> counts() => guard(() async {
    Future<int> count(String table) async =>
        Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM $table'),
        ) ??
        0;
    return (
      profile: await count('profile'),
      routines: await count('routines'),
      exercises: await count('exercises'),
      sets: await count('workout_sets'),
    );
  });

  /// Children first, so no foreign key is ever left pointing nowhere.
  @override
  Future<Result<void>> deleteAllData() => guardWrite(
    _changes,
    () => _db.transaction((txn) async {
      await txn.delete('workout_sets');
      await txn.delete('exercises');
      await txn.delete('routines');
      await txn.delete('profile');
    }),
  );

  @override
  Future<Result<void>> loadSampleData({
    required bool spanish,
    DateTime? today,
  }) => guardWrite(
    _changes,
    () => _db.transaction((txn) async {
      final random = Random(7); // fixed seed: same data every time
      final end = dayOf(today ?? DateTime.now());
      final start = DateTime(end.year, end.month, end.day - 7 * 8);
      final suffix = await _freeSuffix(txn, spanish);

      for (final (index, plan) in _plans(spanish).indexed) {
        final routineId = await txn.insert('routines', {
          'name': '${plan.name}$suffix',
          'description': plan.description,
        });
        final exercises = <({int id, double startKg, int reps})>[];
        for (final (position, e) in plan.exercises.indexed) {
          final id = await txn.insert('exercises', {
            'routine_id': routineId,
            'name': e.name,
            'muscle_group': e.group.dbValue,
            'target_sets': 3,
            'target_reps': e.reps,
            'position': position + 1,
          });
          exercises.add((id: id, startKg: e.startKg, reps: e.reps));
        }
        // Routine `index` is trained on Monday, Wednesday or Friday.
        final batch = txn.batch();
        for (
          var day = start.add(
            Duration(days: (8 - start.weekday + index * 2) % 7),
          );
          !day.isAfter(end);
          day = DateTime(day.year, day.month, day.day + 7)
        ) {
          if (random.nextDouble() < 0.15) continue; // a missed session
          final weeks = day.difference(start).inDays / 7;
          for (final e in exercises) {
            final weight = _round(e.startKg * (1 + 0.025 * weeks));
            for (var set = 1; set <= 3; set++) {
              batch.insert('workout_sets', {
                'exercise_id': e.id,
                'performed_on': dateOnly(day),
                'set_number': set,
                'weight_kg': weight,
                'reps': max(1, e.reps - random.nextInt(3) - (set - 1)),
              });
            }
          }
        }
        await batch.commit(noResult: true);
      }
    }),
  );

  /// " (2)", " (3)"… when sample routines already exist, so loading twice
  /// does not break the unique-name rule.
  Future<String> _freeSuffix(DatabaseExecutor db, bool spanish) async {
    final first = _plans(spanish).first.name;
    for (var n = 1; ; n++) {
      final suffix = n == 1 ? '' : ' ($n)';
      final rows = await db.rawQuery(
        'SELECT 1 FROM routines WHERE name = ? COLLATE NOCASE '
        'AND archived_at IS NULL',
        ['$first$suffix'],
      );
      if (rows.isEmpty) return suffix;
    }
  }

  static double _round(double kg) => (kg / 2.5).round() * 2.5;

  static List<_Plan> _plans(bool es) => [
    _Plan(
      es ? 'Empuje' : 'Push day',
      es ? 'Pecho, hombros y tríceps' : 'Chest, shoulders and triceps',
      [
        _Ex(es ? 'Press de banca' : 'Bench press', MuscleGroup.chest, 60, 8),
        _Ex(
          es ? 'Press militar' : 'Overhead press',
          MuscleGroup.shoulders,
          35,
          10,
        ),
        _Ex(es ? 'Fondos' : 'Dips', MuscleGroup.triceps, 10, 12),
      ],
    ),
    _Plan(
      es ? 'Tirón' : 'Pull day',
      es ? 'Espalda y bíceps' : 'Back and biceps',
      [
        _Ex(es ? 'Peso muerto' : 'Deadlift', MuscleGroup.back, 90, 5),
        _Ex(es ? 'Remo con barra' : 'Barbell row', MuscleGroup.back, 50, 10),
        _Ex(es ? 'Curl de bíceps' : 'Biceps curl', MuscleGroup.biceps, 12, 12),
      ],
    ),
    _Plan(
      es ? 'Pierna' : 'Leg day',
      es ? 'Piernas, glúteos y core' : 'Legs, glutes and core',
      [
        _Ex(es ? 'Sentadilla' : 'Squat', MuscleGroup.legs, 70, 8),
        _Ex(es ? 'Hip thrust' : 'Hip thrust', MuscleGroup.glutes, 60, 10),
        _Ex(es ? 'Plancha con peso' : 'Weighted plank', MuscleGroup.core, 5, 3),
      ],
    ),
  ];
}

class _Plan {
  const _Plan(this.name, this.description, this.exercises);
  final String name;
  final String description;
  final List<_Ex> exercises;
}

class _Ex {
  const _Ex(this.name, this.group, this.startKg, this.reps);
  final String name;
  final MuscleGroup group;
  final double startKg;
  final int reps;
}
