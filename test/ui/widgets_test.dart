import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/repositories/routine_repository.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/ui/auth/sign_in_screen.dart';
import 'package:gym_tracker/ui/auth/sign_in_view_model.dart';
import 'package:gym_tracker/ui/core/view_models/session_controller.dart';
import 'package:gym_tracker/ui/onboarding/profile_form_screen.dart';
import 'package:gym_tracker/ui/onboarding/profile_form_view_model.dart';
import 'package:gym_tracker/ui/progress/progress_screen.dart';
import 'package:gym_tracker/ui/progress/progress_view_model.dart';
import 'package:gym_tracker/ui/routines/routine_list_screen.dart';
import 'package:gym_tracker/ui/routines/routine_list_view_model.dart';
import 'package:gym_tracker/ui/workout/workout_screen.dart';
import 'package:gym_tracker/ui/workout/workout_view_model.dart';

import '../fakes/fakes.dart';

Widget app(Widget home) => MaterialApp(home: home);

void main() {
  testWidgets('sign in: validates input before calling the server', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(
      app(SignInScreen(viewModel: SignInViewModel(auth))),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(auth.isSignedIn, isFalse);

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(auth.isSignedIn, isTrue);
  });

  testWidgets('routine list: empty state, then create a routine', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        RoutineListScreen(
          viewModel: RoutineListViewModel(FakeRoutineRepository()),
          onSignOut: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No routines yet'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Create routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Push day');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Push day'), findsOneWidget);
  });

  testWidgets('workout: log a set and see it listed', (tester) async {
    final routines = FakeRoutineRepository();
    await routines.addExercise(
      'r1',
      const ExerciseDraft(name: 'Bench press', targetSets: 3, targetReps: 8),
    );
    final workouts = FakeWorkoutRepository();
    await tester.pumpWidget(
      app(
        WorkoutScreen(
          routineName: 'Push day',
          viewModel: WorkoutViewModel(
            routines: routines,
            workouts: workouts,
            routineId: 'r1',
            unit: WeightUnit.kg,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Target: 3 × 8'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '60');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.tap(find.text('Log set'));
    await tester.pump();
    expect(find.text('Reps must be 1 to 200'), findsOneWidget);
    expect(workouts.sets, isEmpty);

    await tester.enterText(find.byType(TextFormField).at(1), '8');
    await tester.tap(find.text('Log set'));
    await tester.pumpAndSettle();
    expect(find.text('60 kg × 8'), findsOneWidget);
    expect(workouts.sets.single.reps, 8);
  });

  testWidgets('progress: shows stats and history', (tester) async {
    final workouts = FakeWorkoutRepository();
    for (final (day, kg) in [(20, 60.0), (27, 62.5)]) {
      await workouts.logSet(
        exerciseId: 'e1',
        day: DateTime(2026, 10, day),
        weightKg: kg,
        reps: 8,
      );
    }
    await tester.pumpWidget(
      app(
        ProgressScreen(
          exerciseName: 'Bench press',
          unit: WeightUnit.kg,
          viewModel: ProgressViewModel(workouts, exerciseId: 'e1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('79.2 kg'), findsWidgets); // best estimated 1RM
    expect(find.text('+3.2 kg'), findsOneWidget); // 79.17 - 76.0
    expect(find.text('2026-10-27'), findsOneWidget);
  });

  testWidgets('onboarding: required fields, then saves the profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.reset);
    final profiles = FakeProfileRepository();
    final session = SessionController(
      auth: FakeAuthRepository(signedIn: true),
      profiles: profiles,
    );
    await tester.pumpWidget(
      app(
        ProfileFormScreen(
          viewModel: ProfileFormViewModel(
            profiles: profiles,
            session: session,
            userId: testUserId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start training'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your birth date'), findsOneWidget);
    expect(profiles.profile, isNull);
  });
}
