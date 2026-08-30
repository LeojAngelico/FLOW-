import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/database_provider.dart';
import '../../core/preferences/onboarding_provider.dart';
import '../../features/onboarding/presentation/activity_page.dart';
import '../../features/onboarding/presentation/basics_page.dart';
import '../../features/onboarding/presentation/environment_page.dart';
import '../../features/onboarding/presentation/reminders_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/onboarding/presentation/target_page.dart';
import '../../features/onboarding/presentation/weight_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import 'app_redirect.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final databaseHealthy = ref.read(databaseHealthyProvider);
      final onboardingComplete = ref.read(onboardingCompleteProvider);

      return resolveRedirect(
        databaseHealthy: databaseHealthy,
        onboardingComplete: onboardingComplete,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/basics',
        builder: (context, state) => const BasicsPage(),
      ),
      GoRoute(
        path: '/onboarding/weight',
        builder: (context, state) => const WeightPage(),
      ),
      GoRoute(
        path: '/onboarding/activity',
        builder: (context, state) => const ActivityPage(),
      ),
      GoRoute(
        path: '/onboarding/environment',
        builder: (context, state) => const EnvironmentPage(),
      ),
      GoRoute(
        path: '/onboarding/target',
        builder: (context, state) => const TargetPage(),
      ),
      GoRoute(
        path: '/onboarding/reminders',
        builder: (context, state) => const RemindersPage(),
      ),
    ],
  );
}
