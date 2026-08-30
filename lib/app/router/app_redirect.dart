/// The router's global redirect gate, per 04-user-flows.md §4.1. Kept
/// as a pure function (no BuildContext/Ref) so it's trivially unit
/// tested without standing up a GoRouter or widget tree.
String? resolveRedirect({
  required bool databaseHealthy,
  required bool onboardingComplete,
  required String location,
}) {
  if (!databaseHealthy) {
    return '/recovery';
  }

  final underOnboarding = location.startsWith('/onboarding');

  if (!onboardingComplete && !underOnboarding) {
    return '/onboarding/welcome';
  }

  if (onboardingComplete && underOnboarding) {
    return '/home';
  }

  return null;
}
