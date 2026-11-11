import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/dependencies.dart';
import 'data/local/open_database.dart';
import 'l10n/app_localizations.dart';
import 'routing/router.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/view_models/session_controller.dart';
import 'ui/core/view_models/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = await openAppDatabase();
  runApp(
    MultiProvider(
      providers: appProviders(db, prefs),
      child: const GymTrackerApp(),
    ),
  );
}

/// Root widget: theme, language and router.
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
    final settings = context.watch<SettingsController>();
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(settings.accent, Brightness.light),
      darkTheme: AppTheme.build(settings.accent, Brightness.dark),
      themeMode: settings.themeMode,
      themeAnimationDuration: AppTheme.medium,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
