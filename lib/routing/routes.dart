/// Every path in the app, in one place, so screens never hard-code strings.
abstract final class Routes {
  static const home = '/';
  static const loading = '/loading';
  static const signIn = '/sign-in';
  static const onboarding = '/onboarding';
  static const sessionError = '/session-error';
  static const profile = '/profile';

  static const routinePattern = '/routines/:routineId';
  static const workoutPattern = '/routines/:routineId/workout';
  static const progressPattern = '/exercises/:exerciseId/progress';

  static String routine(String id) => '/routines/$id';
  static String workout(String routineId) => '/routines/$routineId/workout';
  static String progress(String exerciseId) =>
      '/exercises/$exerciseId/progress';
}
