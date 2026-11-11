import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../data/local/database_changes.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../data/repositories/sqlite/sqlite_data_repository.dart';
import '../data/repositories/sqlite/sqlite_profile_repository.dart';
import '../data/repositories/sqlite/sqlite_routine_repository.dart';
import '../data/repositories/sqlite/sqlite_workout_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../ui/core/view_models/session_controller.dart';
import '../ui/core/view_models/settings_controller.dart';

/// The one place that decides which implementation backs each repository
/// (dependency injection). Screens only know the abstract repositories, so
/// tests can build the same tree on an in-memory database.
List<SingleChildWidget> appProviders(
  Database db,
  SharedPreferences prefs, {
  DatabaseChanges? changes,
}) {
  final notifier = changes ?? DatabaseChanges();
  return [
    ChangeNotifierProvider.value(value: notifier),
    Provider<ProfileRepository>(
      create: (_) => SqliteProfileRepository(db, notifier),
    ),
    Provider<RoutineRepository>(
      create: (_) => SqliteRoutineRepository(db, notifier),
    ),
    Provider<WorkoutRepository>(
      create: (_) => SqliteWorkoutRepository(db, notifier),
    ),
    Provider<DataRepository>(create: (_) => SqliteDataRepository(db, notifier)),
    ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
    ChangeNotifierProvider(
      create: (context) =>
          SessionController(context.read<ProfileRepository>())..load(),
    ),
  ];
}
