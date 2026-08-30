import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/app.dart';
import 'package:flow/core/database/database_provider.dart';
import 'package:flow/core/environment/app_environment.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';

void main() {
  setUp(() {
    // AppEnvironment.current is normally populated once in main() before
    // runApp; tests build App() directly so it must be initialized here.
    AppEnvironment.initialize();
  });

  testWidgets(
    'pumping the real App widget for a returning user does not crash and '
    'renders the Home tab',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingCompleteProvider.overrideWithValue(true),
            databaseHealthyProvider.overrideWithValue(true),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Regression guard: App.build previously omitted
      // localizationsDelegates/supportedLocales, so any
      // AppLocalizations.of(context)! call inside the shell/tab pages threw
      // a null-check error the instant the shell built.
      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    },
  );
}
