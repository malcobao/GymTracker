import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/errors/app_exception.dart';
import 'package:gym_tracker/data/local/database_changes.dart';
import 'package:gym_tracker/data/repositories/routine_repository.dart';
import 'package:gym_tracker/data/repositories/sqlite/sqlite_data_repository.dart';
import 'package:gym_tracker/data/repositories/sqlite/sqlite_profile_repository.dart';
import 'package:gym_tracker/data/repositories/sqlite/sqlite_routine_repository.dart';
import 'package:gym_tracker/data/repositories/sqlite/sqlite_workout_repository.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/statistics.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers.dart';

/// Every rule of the schema, checked against a real SQLite database.
void main() {
  late Database db;
  late DatabaseChanges changes;
  late SqliteProfileRepository profiles;
  late SqliteRoutineRepository routines;
  late SqliteWorkoutRepository workouts;
  late SqliteDataRepository data;
  final day = DateTime(2026, 11, 2);

  setUp(() async {
    db = await openTestDatabase();
    changes = DatabaseChanges();
    profiles = SqliteProfileRepository(db, changes);
    routines = SqliteRoutineRepository(db, changes);
    workouts = SqliteWorkoutRepository(db, changes);
    data = SqliteDataRepository(db, changes);
    ok(await profiles.saveProfile(sampleProfile()));
  });

  tearDown(() => db.close());

  /// A routine with one exercise and [sets] logged sets.
  Future<({int routineId, int exerciseId})> routineWithSets(int sets) async {
    final routine = ok(await routines.createRoutine('Push'));
    final exercise = ok(
      await routines.addExercise(
        routine.id,
        const ExerciseDraft(name: 'Bench', muscleGroup: MuscleGroup.chest),
      ),
    );
    for (var i = 0; i < sets; i++) {
      ok(
        await workouts.logSet(
          exerciseId: exercise.id,
          day: day,
          weightKg: 60,
          reps: 8,
        ),
      );
    }
    return (routineId: routine.id, exerciseId: exercise.id);
  }

  group('schema', () {
    test('has exactly the four tables, with foreign keys on', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      expect(tables.map((t) => t['name']), [
        'exercises',
        'profile',
        'routines',
        'workout_sets',
      ]);
      final fk = await db.rawQuery('PRAGMA foreign_keys');
      expect(fk.first.values.first, 1);
    });

    test('CHECK constraints reject out-of-range values', () async {
      final routine = ok(await routines.createRoutine('Push'));
      final bad = [
        () => db.insert('routines', {'name': '   '}),
        () => db.insert('exercises', {
          'routine_id': routine.id,
          'name': 'X',
          'position': 1,
          'target_sets': 50,
        }),
        () => db.insert('exercises', {
          'routine_id': routine.id,
          'name': 'X',
          'position': 1,
          'muscle_group': 'wings',
        }),
        () => db.update('profile', {'height_cm': 20}),
        () => db.insert('profile', {...sampleProfile().toRow(), 'id': 2}),
      ];
      for (final insert in bad) {
        expect(mapError(await _thrown(insert)), isA<InvalidDataException>());
      }
    });

    test('a set must point to an existing exercise', () async {
      final error = await _thrown(
        () => db.insert('workout_sets', {
          'exercise_id': 999,
          'performed_on': '2026-11-02',
          'set_number': 1,
          'weight_kg': 50,
          'reps': 5,
        }),
      );
      expect(error.toString(), contains('FOREIGN KEY constraint failed'));
    });

    test('sets: weight 0–1000 kg and reps 1–200', () async {
      final ids = await routineWithSets(0);
      expect(
        err(
          await workouts.logSet(
            exerciseId: ids.exerciseId,
            day: day,
            weightKg: 1001,
            reps: 5,
          ),
        ),
        isA<InvalidDataException>(),
      );
      expect(
        err(
          await workouts.logSet(
            exerciseId: ids.exerciseId,
            day: day,
            weightKg: 50,
            reps: 0,
          ),
        ),
        isA<InvalidDataException>(),
      );
    });
  });

  group('profile', () {
    test('saving twice updates the single row', () async {
      ok(await profiles.saveProfile(sampleProfile(unit: WeightUnit.lb)));
      final rows = await db.query('profile');
      expect(rows, hasLength(1));
      expect(ok(await profiles.getProfile())!.weightUnit, WeightUnit.lb);
    });
  });

  group('routines', () {
    test('names are unique among active routines, ignoring case', () async {
      ok(await routines.createRoutine('Push day'));
      expect(
        err(await routines.createRoutine('push DAY')),
        isA<DuplicateException>(),
      );
    });

    test('an archived routine frees its name; restoring it clashes', () async {
      final first = ok(await routines.createRoutine('Push'));
      ok(await routines.archiveRoutine(first.id));
      expect(ok(await routines.listRoutines()), isEmpty);
      expect(ok(await routines.listRoutines(archived: true)), hasLength(1));
      ok(await routines.createRoutine('Push'));
      expect(
        err(await routines.restoreRoutine(first.id)),
        isA<DuplicateException>(),
      );
    });

    test('update changes name and description', () async {
      final r = ok(await routines.createRoutine('Push'));
      ok(await routines.updateRoutine(r.id, name: 'Push A', description: 'x'));
      final saved = ok(await routines.getRoutine(r.id));
      expect((saved.name, saved.description), ('Push A', 'x'));
    });

    test('list counts the active exercises of each routine', () async {
      final ids = await routineWithSets(0);
      ok(
        await routines.addExercise(
          ids.routineId,
          const ExerciseDraft(name: 'Dips'),
        ),
      );
      expect(ok(await routines.listRoutines()).single.exerciseCount, 2);
    });

    test('deleting a routine without history cascades to exercises', () async {
      final ids = await routineWithSets(0);
      ok(await routines.deleteRoutine(ids.routineId));
      expect(await db.query('exercises'), isEmpty);
    });

    test('ON DELETE RESTRICT: a routine with logged sets is kept', () async {
      final ids = await routineWithSets(3);
      final error = err(await routines.deleteRoutine(ids.routineId));
      expect(error, isA<InUseException>());
      expect((error as InUseException).setCount, 3);
      expect(await db.query('routines'), hasLength(1));
      expect(await db.query('exercises'), hasLength(1));
      expect(await db.query('workout_sets'), hasLength(3));
    });

    test('withHistory deletes the routine, exercises and sets', () async {
      final ids = await routineWithSets(3);
      ok(await routines.deleteRoutine(ids.routineId, withHistory: true));
      expect(await db.query('workout_sets'), isEmpty);
      expect(await db.query('exercises'), isEmpty);
      expect(await db.query('routines'), isEmpty);
    });

    test('deleting a missing routine is NotFound', () async {
      expect(err(await routines.deleteRoutine(42)), isA<NotFoundException>());
    });
  });

  group('exercises', () {
    test('are appended, reordered and kept unique per routine', () async {
      final r = ok(await routines.createRoutine('Push'));
      final a = ok(
        await routines.addExercise(r.id, const ExerciseDraft(name: 'A')),
      );
      final b = ok(
        await routines.addExercise(r.id, const ExerciseDraft(name: 'B')),
      );
      expect((a.position, b.position), (1, 2));
      expect(
        err(await routines.addExercise(r.id, const ExerciseDraft(name: 'a'))),
        isA<DuplicateException>(),
      );
      ok(await routines.reorderExercises(r.id, [b.id, a.id]));
      expect(ok(await routines.listExercises(r.id)).map((e) => e.name), [
        'B',
        'A',
      ]);
    });

    test('archive hides; restore puts it back at the end', () async {
      final r = ok(await routines.createRoutine('Push'));
      final a = ok(
        await routines.addExercise(r.id, const ExerciseDraft(name: 'A')),
      );
      ok(await routines.addExercise(r.id, const ExerciseDraft(name: 'B')));
      ok(await routines.archiveExercise(a.id));
      expect(ok(await routines.listExercises(r.id)).map((e) => e.name), ['B']);
      ok(await routines.restoreExercise(a.id));
      expect(ok(await routines.listExercises(r.id)).map((e) => e.name), [
        'B',
        'A',
      ]);
    });

    test('RESTRICT protects history; withHistory removes it', () async {
      final ids = await routineWithSets(2);
      final error = err(await routines.deleteExercise(ids.exerciseId));
      expect((error as InUseException).setCount, 2);
      ok(await routines.deleteExercise(ids.exerciseId, withHistory: true));
      expect(await db.query('exercises'), isEmpty);
      expect(await db.query('workout_sets'), isEmpty);
    });

    test('listAllExercises joins the routine name', () async {
      await routineWithSets(0);
      expect(ok(await routines.listAllExercises()).single.routineName, 'Push');
    });
  });

  group('workout sets', () {
    test('numbers sets 1, 2, 3 and renumbers after a delete', () async {
      final ids = await routineWithSets(3);
      final sets = ok(await workouts.listSetsOn([ids.exerciseId], day));
      expect(sets.map((s) => s.setNumber), [1, 2, 3]);
      ok(await workouts.deleteSet(sets.first.id));
      final after = ok(await workouts.listSetsOn([ids.exerciseId], day));
      expect(after.map((s) => s.setNumber), [1, 2]);
      final next = ok(
        await workouts.logSet(
          exerciseId: ids.exerciseId,
          day: day,
          weightKg: 70,
          reps: 5,
        ),
      );
      expect(next.setNumber, 3);
    });

    test('update corrects weight and reps', () async {
      final ids = await routineWithSets(1);
      final set = ok(await workouts.listSetsForExercise(ids.exerciseId)).single;
      ok(await workouts.updateSet(set.id, weightKg: 62.5, reps: 6));
      final saved = ok(await workouts.listSetsForExercise(ids.exerciseId))
          .single;
      expect((saved.weightKg, saved.reps), (62.5, 6));
    });

    test('records joins three tables and applies every filter', () async {
      final ids = await routineWithSets(2);
      final legs = ok(await routines.createRoutine('Legs'));
      final squat = ok(
        await routines.addExercise(
          legs.id,
          const ExerciseDraft(name: 'Squat', muscleGroup: MuscleGroup.legs),
        ),
      );
      ok(
        await workouts.logSet(
          exerciseId: squat.id,
          day: DateTime(2026, 10, 1),
          weightKg: 100,
          reps: 5,
        ),
      );

      final all = ok(await workouts.records(const RecordFilter()));
      expect(all, hasLength(3));
      expect(all.first.routineName, 'Legs'); // oldest first

      Future<int> count(RecordFilter f) async =>
          ok(await workouts.records(f)).length;
      expect(await count(RecordFilter(from: DateTime(2026, 11, 1))), 2);
      expect(await count(RecordFilter(to: DateTime(2026, 10, 31))), 1);
      expect(await count(RecordFilter(routineId: ids.routineId)), 2);
      expect(await count(RecordFilter(exerciseId: squat.id)), 1);
      expect(
        await count(const RecordFilter(muscleGroup: MuscleGroup.chest)),
        2,
      );
    });
  });

  group('data', () {
    test('sample data: 3 routines, 9 exercises, weeks of sets', () async {
      ok(
        await data.loadSampleData(spanish: true, today: DateTime(2026, 11, 10)),
      );
      final counts = ok(await data.counts());
      expect(counts.profile, 1);
      expect(counts.routines, 3);
      expect(counts.exercises, 9);
      expect(counts.sets, greaterThan(150));
      // Loading again adds a second copy with new names, not an error.
      ok(
        await data.loadSampleData(spanish: true, today: DateTime(2026, 11, 10)),
      );
      expect(ok(await data.counts()).routines, 6);
    });

    test('deleteAllData empties the four tables in a valid order', () async {
      await routineWithSets(3);
      ok(await data.deleteAllData());
      expect(ok(await data.counts()), (
        profile: 0,
        routines: 0,
        exercises: 0,
        sets: 0,
      ));
    });

    test('writes notify listeners, reads and failures do not', () async {
      var notified = 0;
      changes.addListener(() => notified++);
      await routines.listRoutines();
      expect(notified, 0);
      ok(await routines.createRoutine('Push'));
      expect(notified, 1);
      err(await routines.createRoutine('Push'));
      expect(notified, 1);
    });
  });
}

Future<Object> _thrown(Future<Object?> Function() action) async {
  try {
    await action();
  } on Object catch (e) {
    return e;
  }
  fail('Expected the database to refuse');
}
