import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flow/app/router/app_router.dart';
import 'package:flow/core/database/database_provider.dart';
import 'package:flow/core/design/theme/flow_theme.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/l10n/generated/app_localizations.dart';

void main() {
  Future<GoRouter> pumpRouter(
    WidgetTester tester, {
    required bool databaseHealthy,
  }) async {
    late GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          databaseHealthyProvider.overrideWithValue(databaseHealthy),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
              theme: FlowTheme.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('every pushed route renders without throwing', (tester) async {
    final router = await pumpRouter(tester, databaseHealthy: true);

    for (final route in [
      '/home/add',
      '/home/trivia',
      '/progress/day/2026-01-01',
      '/awards/streak_7',
      '/profile/target',
      '/profile/reminders',
      '/profile/settings',
      '/profile/settings/about',
    ]) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: 'route $route should render a Scaffold',
      );
    }
  });

  testWidgets('the day-detail route passes the date path parameter through', (
    tester,
  ) async {
    final router = await pumpRouter(tester, databaseHealthy: true);

    router.go('/progress/day/2026-03-15');
    await tester.pumpAndSettle();

    expect(find.text('2026-03-15'), findsOneWidget);
  });

  testWidgets('an unhealthy database redirects to /recovery', (tester) async {
    await pumpRouter(tester, databaseHealthy: false);

    expect(find.text('Data Recovery'), findsOneWidget);
  });
}
