import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/database_provider.dart';
import '../../core/preferences/onboarding_provider.dart';
import '../../features/gamification/presentation/achievement_detail_page.dart';
import '../../features/gamification/presentation/awards_page.dart';
import '../../features/hydration/presentation/add_water/add_water_page.dart';
import '../../features/hydration/presentation/day_detail/day_detail_page.dart';
import '../../features/hydration/presentation/home/home_page.dart';
import '../../features/hydration/presentation/progress/progress_page.dart';
import '../../features/hydration/presentation/target_settings/target_settings_page.dart';
import '../../features/onboarding/presentation/activity_page.dart';
import '../../features/onboarding/presentation/basics_page.dart';
import '../../features/onboarding/presentation/environment_page.dart';
import '../../features/onboarding/presentation/recovery_page.dart';
import '../../features/onboarding/presentation/reminders_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/onboarding/presentation/target_page.dart';
import '../../features/onboarding/presentation/weight_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/reminders/presentation/reminder_settings_page.dart';
import '../../features/settings/presentation/about_page.dart';
import '../../features/settings/presentation/general_settings_page.dart';
import '../../features/settings/presentation/profile_page.dart';
import '../../features/trivia/presentation/trivia_page.dart';
import '../main_shell.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/awards',
                builder: (context, state) => const AwardsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/home/add',
        builder: (context, state) => const AddWaterPage(),
      ),
      GoRoute(
        path: '/home/trivia',
        builder: (context, state) => const TriviaPage(),
      ),
      GoRoute(
        path: '/progress/day/:date',
        builder: (context, state) =>
            DayDetailPage(date: state.pathParameters['date']!),
      ),
      GoRoute(
        path: '/awards/:achievementId',
        builder: (context, state) => AchievementDetailPage(
          achievementId: state.pathParameters['achievementId']!,
        ),
      ),
      GoRoute(
        path: '/profile/target',
        builder: (context, state) => const TargetSettingsPage(),
      ),
      GoRoute(
        path: '/profile/reminders',
        builder: (context, state) => const ReminderSettingsPage(),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const GeneralSettingsPage(),
      ),
      GoRoute(
        path: '/profile/settings/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/recovery',
        builder: (context, state) => const RecoveryPage(),
      ),
    ],
  );
}
