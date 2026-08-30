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
  final atSplash = location == '/';

  if (!onboardingComplete && !underOnboarding) {
    return '/onboarding/welcome';
  }

  // Also sweeps a returning user off the bare '/' splash location — Task
  // 31 only covered leaving /onboarding, which left a returning user
  // stuck on SplashPage forever since '/' is neither "under onboarding"
  // nor a route the app ever navigates away from on its own. Found and
  // fixed while implementing Task 33's shell (see task-33-34-report.md).
  if (onboardingComplete && (underOnboarding || atSplash)) {
    return '/home';
  }

  return null;
}
