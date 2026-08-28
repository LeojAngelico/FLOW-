import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/src/framework.dart';
import 'package:flow/core/design/theme/flow_theme.dart';

/// Standard wrapper for widget tests in this project: a 360x640dp
/// (the design system's reference viewport) MaterialApp using the real
/// FlowTheme, inside a fresh ProviderScope.
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
        home: Scaffold(body: child),
      ),
    ),
  );
}
