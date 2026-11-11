import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/core/app_theme.dart';
import '../ui/core/labels.dart';
import '../ui/core/view_models/session_controller.dart';
import '../ui/core/widgets/state_views.dart';
import '../ui/profile/profile_form_screen.dart';
import '../ui/progress/progress_screen.dart';
import '../ui/reports/reports_screen.dart';
import '../ui/routines/routine_detail_screen.dart';
import '../ui/routines/routine_list_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/shell/app_shell.dart';
import '../ui/statistics/statistics_screen.dart';
import '../ui/workout/workout_screen.dart';
import 'routes.dart';

/// Builds the router. It re-checks [redirect] whenever [session] changes:
/// no profile → onboarding; profile saved → the app.
GoRouter createRouter(SessionController session) => GoRouter(
  initialLocation: Routes.routines,
  refreshListenable: session,
  redirect: (context, state) => redirect(session.status, state.matchedLocation),
  routes: [
    GoRoute(
      path: Routes.loading,
      builder: (_, _) => const Scaffold(body: LoadingView()),
    ),
    GoRoute(
      path: Routes.startupError,
      builder: (context, _) => Scaffold(
        body: ErrorView(
          message: context.l10n.errorStorage,
          onRetry: session.load,
        ),
      ),
    ),
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (_, state) =>
          _fade(state, const ProfileFormScreen(isOnboarding: true)),
    ),
    // The four tabs; each keeps its own navigation stack.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.routines,
              builder: (_, _) => const RoutineListScreen(),
            ),
            GoRoute(
              path: Routes.routinePattern,
              pageBuilder: (_, state) => _slide(
                state,
                RoutineDetailScreen(
                  routineId: int.parse(state.pathParameters['routineId']!),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.statistics,
              builder: (_, _) => const StatisticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.reports,
              builder: (_, _) => const ReportsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (_, _) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'profile',
                  pageBuilder: (_, state) =>
                      _slide(state, const ProfileFormScreen()),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Full-screen pages above the tabs.
    GoRoute(
      path: Routes.workoutPattern,
      pageBuilder: (_, state) => _slide(
        state,
        WorkoutScreen(routineId: int.parse(state.pathParameters['routineId']!)),
      ),
    ),
    GoRoute(
      path: Routes.progressPattern,
      pageBuilder: (_, state) => _slide(
        state,
        ProgressScreen(
          exerciseId: int.parse(state.pathParameters['exerciseId']!),
          exerciseName: state.extra is String ? state.extra! as String : '',
        ),
      ),
    ),
  ],
);

/// Where to send the user for a session [status] at [location]; null means
/// "stay". A pure function, so it is unit-tested.
String? redirect(SessionStatus status, String location) {
  String? goTo(String target) => location == target ? null : target;
  return switch (status) {
    SessionStatus.loading => goTo(Routes.loading),
    SessionStatus.needsOnboarding => goTo(Routes.onboarding),
    SessionStatus.error => goTo(Routes.startupError),
    SessionStatus.ready =>
      const {
            Routes.loading,
            Routes.onboarding,
            Routes.startupError,
          }.contains(location)
          ? Routes.routines
          : null,
  };
}

/// Pushed pages slide in from the right while fading in.
CustomTransitionPage<void> _slide(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: AppTheme.medium,
      reverseTransitionDuration: AppTheme.fast,
      child: child,
      transitionsBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: AppTheme.slow,
      child: child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
