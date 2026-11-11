import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/errors/app_exception.dart';
import 'package:gym_tracker/data/repositories/routine_repository.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/models/routine.dart';
import 'package:gym_tracker/ui/auth/sign_in_view_model.dart';
import 'package:gym_tracker/ui/core/view_models/view_state.dart';
import 'package:gym_tracker/ui/progress/progress_view_model.dart';
import 'package:gym_tracker/ui/routines/routine_detail_view_model.dart';
import 'package:gym_tracker/ui/routines/routine_list_view_model.dart';
import 'package:gym_tracker/ui/workout/workout_view_model.dart';

import '../fakes/fakes.dart';

void main() {
  group('RoutineListViewModel', () {
    test('empty, then loaded after creating a routine', () async {
      final vm = RoutineListViewModel(FakeRoutineRepository());
      await vm.load();
      expect(vm.state, isA<Empty<List<Routine>>>());

      expect(await vm.create('Push day', null), isNull);
      expect((vm.state as Loaded<List<Routine>>).data.single.name, 'Push day');
    });

    test('a duplicate name returns the message and keeps the list', () async {
      final vm = RoutineListViewModel(FakeRoutineRepository());
      await vm.create('Push day', null);
      expect(
        await vm.create('Push day', null),
        'You already have a routine with that name.',
      );
      expect((vm.state as Loaded<List<Routine>>).data, hasLength(1));
    });

    test('archiving hides the routine', () async {
      final vm = RoutineListViewModel(FakeRoutineRepository());
      await vm.create('Push day', null);
      final id = (vm.state as Loaded<List<Routine>>).data.single.id;
      await vm.archive(id);
      expect(vm.state, isA<Empty<List<Routine>>>());
    });

    test('a failed load shows the error', () async {
      final vm = RoutineListViewModel(
        FakeRoutineRepository()..failure = const NetworkException(),
      );
      await vm.load();
      expect(vm.state, isA<Failed<List<Routine>>>());
    });
  });

  group('RoutineDetailViewModel', () {
    test('reorders and saves the new order', () async {
      final repo = FakeRoutineRepository();
      final vm = RoutineDetailViewModel(repo, routineId: 'r1');
      await vm.add(const ExerciseDraft(name: 'Bench press'));
      await vm.add(const ExerciseDraft(name: 'Overhead press'));
      await vm.add(const ExerciseDraft(name: 'Dips'));

      // Move "Dips" (index 2) to the top.
      expect(await vm.move(2, 0), isNull);
      expect(vm.exercises.map((e) => e.name), [
        'Dips',
        'Bench press',
        'Overhead press',
      ]);
      expect(repo.lastReorder, [for (final e in vm.exercises) e.id]);
    });

    test('a failed reorder reloads the saved order', () async {
      final repo = FakeRoutineRepository();
      final vm = RoutineDetailViewModel(repo, routineId: 'r1');
      await vm.add(const ExerciseDraft(name: 'A'));
      await vm.add(const ExerciseDraft(name: 'B'));
      repo.failure = const NetworkException();
      expect(await vm.move(1, 0), startsWith('No internet'));
      expect(vm.state, isA<Failed>());
    });
  });

  group('WorkoutViewModel', () {
    Future<(WorkoutViewModel, FakeWorkoutRepository)> setUpWorkout(
      WeightUnit unit,
    ) async {
      final routines = FakeRoutineRepository();
      await routines.addExercise('r1', const ExerciseDraft(name: 'Bench'));
      final workouts = FakeWorkoutRepository();
      final vm = WorkoutViewModel(
        routines: routines,
        workouts: workouts,
        routineId: 'r1',
        unit: unit,
        day: DateTime(2026, 11, 11, 18, 45),
      );
      await vm.load();
      return (vm, workouts);
    }

    test('logs numbered sets for today and deletes them', () async {
      final (vm, workouts) = await setUpWorkout(WeightUnit.kg);
      final id = vm.exercisesForTest.single.exercise.id;
      expect(await vm.logSet(id, 60, 8), isNull);
      expect(await vm.logSet(id, 62.5, 6), isNull);

      final sets = vm.exercisesForTest.single.sets;
      expect(sets.map((s) => s.setNumber), [1, 2]);
      expect(sets.last.weightKg, 62.5);
      expect(sets.first.performedOn, DateTime(2026, 11, 11));

      await vm.deleteSet(sets.first);
      expect(vm.exercisesForTest.single.sets, hasLength(1));
      expect(workouts.sets, hasLength(1));
    });

    test('weights typed in pounds are stored in kilograms', () async {
      final (vm, workouts) = await setUpWorkout(WeightUnit.lb);
      final id = vm.exercisesForTest.single.exercise.id;
      await vm.logSet(id, 100, 5);
      expect(workouts.sets.single.weightKg, 45.36);
    });

    test('a failed save returns the message', () async {
      final (vm, workouts) = await setUpWorkout(WeightUnit.kg);
      workouts.failure = const NetworkException();
      final id = vm.exercisesForTest.single.exercise.id;
      expect(await vm.logSet(id, 60, 8), startsWith('No internet'));
    });
  });

  test(
    'ProgressViewModel: empty without sets, daily progress with sets',
    () async {
      final workouts = FakeWorkoutRepository();
      final vm = ProgressViewModel(workouts, exerciseId: 'e1');
      await vm.load();
      expect(vm.state, isA<Empty>());

      await workouts.logSet(
        exerciseId: 'e1',
        day: DateTime(2026, 11, 1),
        weightKg: 60,
        reps: 8,
      );
      await vm.load();
      expect(vm.state, isA<Loaded>());
    },
  );

  group('SignInViewModel', () {
    test('wrong password shows the error', () async {
      final vm = SignInViewModel(FakeAuthRepository());
      await vm.submit('a@b.co', 'wrong-password');
      expect(vm.error, 'Wrong email or password.');
    });

    test('sign up that needs confirmation switches back to sign in', () async {
      final vm = SignInViewModel(
        FakeAuthRepository()..requireEmailConfirmation = true,
      )..toggleMode();
      await vm.submit('a@b.co', 'password123');
      expect(vm.info, startsWith('Account created'));
      expect(vm.mode, AuthMode.signIn);
    });
  });
}
