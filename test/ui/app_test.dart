import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/config/dependencies.dart';
import 'package:gym_tracker/data/repositories/sqlite/sqlite_data_repository.dart';
import 'package:gym_tracker/data/repositories/sqlite/sqlite_profile_repository.dart';
import 'package:gym_tracker/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers.dart';

/// End-to-end widget tests: the real app (router, providers, screens,
/// repositories) on an in-memory SQLite database.
void main() {
  late Database db;

  setUp(() async {
    db = await openTestDatabase();
  });
  tearDown(() => db.close());

  Future<void> pumpApp(
    WidgetTester tester, {
    bool withProfile = true,
    bool withSampleData = false,
    String language = 'en',
  }) async {
    SharedPreferences.setMockInitialValues({'language': language});
    final prefs = await SharedPreferences.getInstance();
    if (withProfile) {
      ok(await SqliteProfileRepository(db).saveProfile(sampleProfile()));
    }
    if (withSampleData) {
      ok(await SqliteDataRepository(db).loadSampleData(spanish: false));
    }
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: appProviders(db, prefs),
        child: const GymTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch: onboarding validates live, then opens the app', (
    tester,
  ) async {
    await pumpApp(tester, withProfile: false);
    expect(find.text('Tell us about you'), findsOneWidget);

    // Real-time validation: an out-of-range height is flagged while typing,
    // untouched fields are not.
    await tester.enterText(find.widgetWithText(TextFormField, 'Height'), '999');
    await tester.pump();
    expect(find.text('Must be between 50 and 272'), findsOneWidget);
    expect(find.text('This field is required'), findsNothing);

    await tester.tap(find.text('Start training'));
    await tester.pump();
    expect(find.text('This field is required'), findsWidgets);
    expect(await db.query('profile'), isEmpty);
  });

  testWidgets('the whole app follows the chosen language', (tester) async {
    await pumpApp(tester, language: 'es');
    expect(find.text('Mis rutinas'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });

  testWidgets('routines: create, and duplicates are rejected while typing', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.textContaining('No routines yet'), findsOneWidget);

    await tester.tap(find.text('Create routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Push day');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Push day'), findsOneWidget);
    expect(await db.query('routines'), hasLength(1));
    await tester.pump(const Duration(seconds: 5)); // snack bar goes away
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'push DAY');
    await tester.pump();
    expect(find.text('That name already exists'), findsOneWidget);
  });

  testWidgets('deleting a routine with history offers to archive it', (
    tester,
  ) async {
    await pumpApp(tester, withSampleData: true);
    await tester.tap(find.byTooltip('More options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // The database refused (ON DELETE RESTRICT); nothing was deleted.
    expect(find.textContaining('has history'), findsOneWidget);
    expect(await db.query('routines'), hasLength(3));

    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();
    expect(find.text('Routine archived'), findsOneWidget);
    final archived = await db.query(
      'routines',
      where: 'archived_at IS NOT NULL',
    );
    expect(archived, hasLength(1));
  });

  testWidgets('statistics: KPIs and charts with their parameters', (
    tester,
  ) async {
    await pumpApp(tester, withSampleData: true);
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Training days'), findsOneWidget);
    expect(find.text('Week streak'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Top exercises'), 300);
    expect(find.text('Progress over time'), findsOneWidget);
    expect(find.text('Distribution by muscle group'), findsOneWidget);
    expect(find.text('Training days by weekday'), findsOneWidget);
  });

  testWidgets('reports: the report type changes the columns', (tester) async {
    await pumpApp(tester, withSampleData: true);
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Best est. 1RM'), findsWidgets); // by exercise
    await tester.tap(find.text('Set log'));
    await tester.pumpAndSettle();
    expect(find.text('Set'), findsWidgets);
    expect(find.text('Total'), findsWidgets);
  });
}
