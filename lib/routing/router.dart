import 'package:go_router/go_router.dart';

import '../ui/home/home_screen.dart';
import 'routes.dart';

/// Builds the app's router. Sign-in and onboarding redirects are added in the
/// login milestone.
GoRouter createRouter() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
  ],
);
