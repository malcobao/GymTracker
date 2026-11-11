import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/memory/in_memory_repositories.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../data/repositories/supabase/supabase_auth_repository.dart';
import '../data/repositories/supabase/supabase_profile_repository.dart';
import '../data/repositories/supabase/supabase_routine_repository.dart';
import '../data/repositories/supabase/supabase_workout_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../ui/core/view_models/session_controller.dart';

/// The one place that decides which implementation backs each repository.
/// Tests build the same tree with fake repositories instead.
List<SingleChildWidget> appProviders(SupabaseClient client) => [
  ChangeNotifierProvider<AuthRepository>(
    create: (_) => SupabaseAuthRepository(client.auth),
  ),
  Provider<ProfileRepository>(create: (_) => SupabaseProfileRepository(client)),
  Provider<RoutineRepository>(create: (_) => SupabaseRoutineRepository(client)),
  Provider<WorkoutRepository>(create: (_) => SupabaseWorkoutRepository(client)),
  ChangeNotifierProvider(
    create: (context) => SessionController(
      auth: context.read<AuthRepository>(),
      profiles: context.read<ProfileRepository>(),
    ),
  ),
];

/// Demo mode: everything in memory, no network. Used when the app is started
/// without Supabase settings. The given repositories may be pre-seeded.
List<SingleChildWidget> demoProviders({
  required InMemoryRoutineRepository routines,
  required InMemoryWorkoutRepository workouts,
}) => [
  ChangeNotifierProvider<AuthRepository>(
    create: (_) => InMemoryAuthRepository(),
  ),
  Provider<ProfileRepository>(create: (_) => InMemoryProfileRepository()),
  Provider<RoutineRepository>.value(value: routines),
  Provider<WorkoutRepository>.value(value: workouts),
  ChangeNotifierProvider(
    create: (context) => SessionController(
      auth: context.read<AuthRepository>(),
      profiles: context.read<ProfileRepository>(),
    ),
  ),
];
