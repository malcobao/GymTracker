import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/errors/app_exception.dart';
import 'package:gym_tracker/routing/router.dart';
import 'package:gym_tracker/routing/routes.dart';
import 'package:gym_tracker/ui/core/view_models/session_controller.dart';

import '../fakes/fakes.dart';

void main() {
  group('SessionController', () {
    test('signed out', () async {
      final session = SessionController(
        auth: FakeAuthRepository(),
        profiles: FakeProfileRepository(),
      );
      await pumpEventQueue();
      expect(session.status, SessionStatus.signedOut);
    });

    test(
      'signed in without a profile needs onboarding, then becomes ready',
      () async {
        final profiles = FakeProfileRepository();
        final session = SessionController(
          auth: FakeAuthRepository(signedIn: true),
          profiles: profiles,
        );
        await pumpEventQueue();
        expect(session.status, SessionStatus.needsOnboarding);

        session.profileSaved(sampleProfile());
        expect(session.status, SessionStatus.ready);
        expect(session.profile?.displayName, 'Cristian');
      },
    );

    test('signing in loads the profile; signing out clears it', () async {
      final auth = FakeAuthRepository();
      final session = SessionController(
        auth: auth,
        profiles: FakeProfileRepository(profile: sampleProfile()),
      );
      await auth.signIn('a@b.co', auth.password!);
      await pumpEventQueue();
      expect(session.status, SessionStatus.ready);

      await session.signOut();
      await pumpEventQueue();
      expect(session.status, SessionStatus.signedOut);
      expect(session.profile, isNull);
    });

    test('a failed profile load shows the error state', () async {
      final session = SessionController(
        auth: FakeAuthRepository(signedIn: true),
        profiles: FakeProfileRepository()..failure = const NetworkException(),
      );
      await pumpEventQueue();
      expect(session.status, SessionStatus.error);
      expect(session.errorMessage, startsWith('No internet connection'));
    });
  });

  group('redirect', () {
    test('signed-out users always land on sign in', () {
      expect(redirect(SessionStatus.signedOut, Routes.home), Routes.signIn);
      expect(redirect(SessionStatus.signedOut, Routes.signIn), isNull);
    });

    test('users without a profile must finish onboarding', () {
      expect(
        redirect(SessionStatus.needsOnboarding, Routes.home),
        Routes.onboarding,
      );
    });

    test('ready users leave the auth screens but may go anywhere else', () {
      expect(redirect(SessionStatus.ready, Routes.signIn), Routes.home);
      expect(redirect(SessionStatus.ready, Routes.onboarding), Routes.home);
      expect(redirect(SessionStatus.ready, Routes.routine('r1')), isNull);
    });
  });
}
