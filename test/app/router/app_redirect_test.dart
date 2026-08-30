import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/router/app_redirect.dart';

void main() {
  test(
    'redirects to /recovery when the database failed to open, regardless of location',
    () {
      expect(
        resolveRedirect(
          databaseHealthy: false,
          onboardingComplete: true,
          location: '/home',
        ),
        '/recovery',
      );
      expect(
        resolveRedirect(
          databaseHealthy: false,
          onboardingComplete: false,
          location: '/onboarding/welcome',
        ),
        '/recovery',
      );
    },
  );

  test(
    'redirects to /onboarding/welcome when onboarding is incomplete and not already there',
    () {
      expect(
        resolveRedirect(
          databaseHealthy: true,
          onboardingComplete: false,
          location: '/home',
        ),
        '/onboarding/welcome',
      );
    },
  );

  test(
    'does not redirect when onboarding is incomplete and already under /onboarding',
    () {
      expect(
        resolveRedirect(
          databaseHealthy: true,
          onboardingComplete: false,
          location: '/onboarding/weight',
        ),
        isNull,
      );
    },
  );

  test(
    'redirects to /home when onboarding is complete but location is under /onboarding',
    () {
      expect(
        resolveRedirect(
          databaseHealthy: true,
          onboardingComplete: true,
          location: '/onboarding/welcome',
        ),
        '/home',
      );
    },
  );

  test(
    'does not redirect when onboarding is complete and location is outside /onboarding',
    () {
      expect(
        resolveRedirect(
          databaseHealthy: true,
          onboardingComplete: true,
          location: '/progress',
        ),
        isNull,
      );
    },
  );

  test('/recovery takes priority over the onboarding rules', () {
    expect(
      resolveRedirect(
        databaseHealthy: false,
        onboardingComplete: true,
        location: '/onboarding/welcome',
      ),
      '/recovery',
    );
  });
}
