import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/router/app_router.dart';
import 'package:flow/core/database/database_provider.dart';
import 'package:flow/core/design/theme/flow_theme.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('a returning user lands on Home with all 4 tabs visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
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

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Awards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping the Progress tab navigates to the Progress screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
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

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Progress'), findsOneWidget);
  });
}
