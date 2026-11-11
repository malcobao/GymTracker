import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/config/demo_data.dart';
import 'package:gym_tracker/config/dependencies.dart';
import 'package:gym_tracker/main.dart';
import 'package:provider/provider.dart';

import 'fakes/fakes.dart';

void main() {
  testWidgets('demo mode: sign up, onboarding gate, seeded routine', (
    tester,
  ) async {
    final routines = InMemoryRoutineRepository();
    final workouts = InMemoryWorkoutRepository();
    await seedDemoData(routines, workouts, today: DateTime(2026, 11, 11));

    await tester.pumpWidget(
      MultiProvider(
        providers: demoProviders(routines: routines, workouts: workouts),
        child: const GymTrackerApp(demoMode: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gym Tracker'), findsOneWidget); // sign-in screen
    expect(find.byType(Banner), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'demo@gym.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'anything123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Tell us about you'), findsOneWidget); // onboarding
  });

  test('seed: one routine, three exercises, two bench sessions', () async {
    final routines = InMemoryRoutineRepository();
    final workouts = InMemoryWorkoutRepository();
    await seedDemoData(routines, workouts, today: DateTime(2026, 11, 11));
    expect(routines.routines.single.name, 'Push day');
    expect(routines.exercises.map((e) => e.name), [
      'Bench press',
      'Overhead press',
      'Dips',
    ]);
    expect(workouts.sets, hasLength(6));
    expect(workouts.sets.first.performedOn, DateTime(2026, 10, 28));
  });
}
