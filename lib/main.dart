import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/demo_data.dart';
import 'config/dependencies.dart';
import 'config/env.dart';
import 'data/repositories/memory/in_memory_repositories.dart';
import 'routing/router.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/view_models/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = Env.fromBuildTime();
  if (!env.isValid) {
    // No Supabase settings: run the offline demo with sample data.
    final routines = InMemoryRoutineRepository();
    final workouts = InMemoryWorkoutRepository();
    await seedDemoData(routines, workouts);
    runApp(
      MultiProvider(
        providers: demoProviders(routines: routines, workouts: workouts),
        child: const GymTrackerApp(demoMode: true),
      ),
    );
    return;
  }
  await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabasePublishableKey,
  );
  runApp(
    MultiProvider(
      providers: appProviders(Supabase.instance.client),
      child: const GymTrackerApp(),
    ),
  );
}

/// Root widget: wires the theme and the router together.
class GymTrackerApp extends StatefulWidget {
  const GymTrackerApp({this.demoMode = false, super.key});

  /// Shows a "DEMO" ribbon: data is kept in memory only.
  final bool demoMode;

  @override
  State<GymTrackerApp> createState() => _GymTrackerAppState();
}

class _GymTrackerAppState extends State<GymTrackerApp> {
  late final GoRouter _router = createRouter(context.read<SessionController>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gym Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: !widget.demoMode,
      builder: (context, child) => widget.demoMode
          ? Banner(
              message: 'DEMO',
              // Bottom start: top end would cover the app bar actions.
              location: BannerLocation.bottomStart,
              child: child!,
            )
          : child!,
    );
  }
}
