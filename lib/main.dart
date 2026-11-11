import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/dependencies.dart';
import 'config/env.dart';
import 'routing/router.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/view_models/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = Env.fromBuildTime();
  if (!env.isValid) {
    runApp(ConfigErrorApp(missing: env.problems));
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
  const GymTrackerApp({super.key});

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
    );
  }
}

/// Shown instead of the app when it was built without its Supabase settings.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({required this.missing, super.key});

  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'The app was built without its configuration.\n\n'
              'Missing or invalid: ${missing.join(', ')}\n\n'
              'Run it with --dart-define=SUPABASE_URL=... and '
              '--dart-define=SUPABASE_PUBLISHABLE_KEY=... (see README).',
            ),
          ),
        ),
      ),
    );
  }
}
