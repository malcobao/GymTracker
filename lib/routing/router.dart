import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../domain/models/enums.dart';
import '../domain/models/exercise.dart';
import '../domain/models/routine.dart';
import '../ui/auth/sign_in_screen.dart';
import '../ui/auth/sign_in_view_model.dart';
import '../ui/core/view_models/session_controller.dart';
import '../ui/core/widgets/error_view.dart';
import '../ui/core/widgets/loading_view.dart';
import '../ui/onboarding/profile_form_screen.dart';
import '../ui/onboarding/profile_form_view_model.dart';
import '../ui/progress/progress_screen.dart';
import '../ui/progress/progress_view_model.dart';
import '../ui/routines/routine_detail_screen.dart';
import '../ui/routines/routine_detail_view_model.dart';
import '../ui/routines/routine_list_screen.dart';
import '../ui/routines/routine_list_view_model.dart';
import '../ui/workout/workout_screen.dart';
import '../ui/workout/workout_view_model.dart';
import 'routes.dart';

/// Builds the router. It re-checks [redirect] whenever [session] changes, so
/// signing in or out, or finishing onboarding, moves to the right screen.
GoRouter createRouter(SessionController session) => GoRouter(
  initialLocation: Routes.home,
  refreshListenable: session,
  redirect: (context, state) => redirect(session.status, state.matchedLocation),
  routes: [
    GoRoute(
      path: Routes.loading,
      builder: (context, state) => const Scaffold(body: LoadingView()),
    ),
    GoRoute(
      path: Routes.sessionError,
      builder: (context, state) => Scaffold(
        body: ErrorView(
          message: session.errorMessage ?? 'Could not load your profile.',
          onRetry: session.reload,
        ),
      ),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => SignInScreen(
        viewModel: SignInViewModel(context.read<AuthRepository>()),
      ),
    ),
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) =>
          ProfileFormScreen(viewModel: _profileViewModel(context, session)),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => RoutineListScreen(
        viewModel: RoutineListViewModel(context.read<RoutineRepository>()),
        onSignOut: session.signOut,
      ),
      routes: [
        GoRoute(
          path: Routes.profile.substring(1),
          builder: (context, state) =>
              ProfileFormScreen(viewModel: _profileViewModel(context, session)),
        ),
      ],
    ),
    GoRoute(
      path: Routes.routinePattern,
      builder: (context, state) {
        final id = state.pathParameters['routineId']!;
        final routine = state.extra is Routine ? state.extra! as Routine : null;
        return RoutineDetailScreen(
          title: routine?.name ?? 'Routine',
          viewModel: RoutineDetailViewModel(
            context.read<RoutineRepository>(),
            routineId: id,
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.workoutPattern,
      builder: (context, state) => WorkoutScreen(
        routineName: state.extra is String ? state.extra! as String : 'Workout',
        viewModel: WorkoutViewModel(
          routines: context.read<RoutineRepository>(),
          workouts: context.read<WorkoutRepository>(),
          routineId: state.pathParameters['routineId']!,
          unit: session.profile?.weightUnit ?? WeightUnit.kg,
        ),
      ),
    ),
    GoRoute(
      path: Routes.progressPattern,
      builder: (context, state) {
        final exercise = state.extra is Exercise
            ? state.extra! as Exercise
            : null;
        return ProgressScreen(
          exerciseName: exercise?.name ?? 'Progress',
          unit: session.profile?.weightUnit ?? WeightUnit.kg,
          viewModel: ProgressViewModel(
            context.read<WorkoutRepository>(),
            exerciseId: state.pathParameters['exerciseId']!,
          ),
        );
      },
    ),
  ],
);

ProfileFormViewModel _profileViewModel(
  BuildContext context,
  SessionController session,
) => ProfileFormViewModel(
  profiles: context.read<ProfileRepository>(),
  session: session,
  userId: context.read<AuthRepository>().userId ?? '',
);

/// Where to send the user for a given session [status] and [location];
/// null means "stay". Kept as a pure function so it can be unit-tested.
String? redirect(SessionStatus status, String location) {
  String? goTo(String target) => location == target ? null : target;
  return switch (status) {
    SessionStatus.loading => goTo(Routes.loading),
    SessionStatus.signedOut => goTo(Routes.signIn),
    SessionStatus.needsOnboarding => goTo(Routes.onboarding),
    SessionStatus.error => goTo(Routes.sessionError),
    SessionStatus.ready =>
      const {
            Routes.loading,
            Routes.signIn,
            Routes.onboarding,
            Routes.sessionError,
          }.contains(location)
          ? Routes.home
          : null,
  };
}
