import 'package:flutter/material.dart';

import 'routing/router.dart';
import 'ui/core/app_theme.dart';

void main() {
  runApp(GymTrackerApp());
}

/// Root widget: wires the theme and the router together.
class GymTrackerApp extends StatelessWidget {
  GymTrackerApp({super.key});

  final _router = createRouter();

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
