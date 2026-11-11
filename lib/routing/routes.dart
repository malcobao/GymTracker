/// Every path in the app, in one place, so screens never hard-code strings.
abstract final class Routes {
  static const loading = '/loading';
  static const startupError = '/error';
  static const onboarding = '/onboarding';

  // The four tabs of the bottom navigation bar.
  static const routines = '/';
  static const statistics = '/statistics';
  static const reports = '/reports';
  static const settings = '/settings';

  static const profile = '/settings/profile';

  static const routinePattern = '/routines/:routineId';
  static const workoutPattern = '/routines/:routineId/workout';
  static const progressPattern = '/exercises/:exerciseId/progress';

  static String routine(int id) => '/routines/$id';
  static String workout(int routineId) => '/routines/$routineId/workout';
  static String progress(int exerciseId) => '/exercises/$exerciseId/progress';
}
