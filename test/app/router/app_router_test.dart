import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/router/app_router.dart';
import 'package:flow/core/design/theme/flow_theme.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/core/database/database_provider.dart';
import 'package:flow/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required bool onboardingComplete,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(onboardingComplete),
          databaseHealthyProvider.overrideWithValue(true),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            routerConfig: ref.watch(appRouterProvider),
            theme: FlowTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a new user (onboarding incomplete) lands on the Welcome screen',
    (tester) async {
      await pumpApp(tester, onboardingComplete: false);

      expect(find.text('Meet Bloop, your hydration companion'), findsOneWidget);
    },
  );

  testWidgets(
    'a returning user (onboarding complete) is redirected off the splash screen to Home',
    (tester) async {
      await pumpApp(tester, onboardingComplete: true);

      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    },
  );
}
