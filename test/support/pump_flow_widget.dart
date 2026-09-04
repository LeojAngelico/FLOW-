import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/theme/flow_theme.dart';
import 'package:flow/l10n/generated/app_localizations.dart';

/// Standard wrapper for widget tests in this project: a 360x640dp
/// (the design system's reference viewport) MaterialApp using the real
/// FlowTheme, inside a fresh ProviderScope.
///
/// Carries `AppLocalizations.localizationsDelegates`/`supportedLocales`
/// (final-review a11y follow-up: FlowBackButton was the first CMP-*
/// component to call `AppLocalizations.of(context)`, and without these
/// it returns null rather than throwing a clear error) — every
/// component test gets it for free rather than each needing its own
/// fix.
Future<void> pumpFlowWidget(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: brightness == Brightness.light
            ? FlowTheme.light
            : FlowTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
}
