import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/back_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets(
    'has a 48x48dp tappable content area (51dp tall including the 3dp depth offset)',
    (tester) async {
      await pumpFlowWidget(tester, FlowBackButton(onPressed: () {}));

      // Same footprint pattern as CMP-01 PrimaryButton (56 + 4 = 60): the
      // widget's total height includes the depth offset beneath the
      // 48dp tappable content.
      expect(tester.getSize(find.byType(FlowBackButton)), const Size(48, 51));
    },
  );

  testWidgets('renders the pixel chevron-left icon asset', (tester) async {
    await pumpFlowWidget(tester, FlowBackButton(onPressed: () {}));

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      FlowBackButton(onPressed: () => tapped = true),
    );

    await tester.tap(find.byType(FlowBackButton));
    expect(tapped, isTrue);
  });

  testWidgets('exposes button semantics with an accessible "Back" label '
      '(icon-only, no visible text a screen reader could fall back on)', (
    tester,
  ) async {
    await pumpFlowWidget(tester, FlowBackButton(onPressed: () {}));

    final data = tester.getSemantics(find.byType(FlowBackButton));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.label, 'Back');
  });

  testWidgets('is reported as disabled semantics when onPressed is null', (
    tester,
  ) async {
    await pumpFlowWidget(tester, const FlowBackButton(onPressed: null));

    final data = tester.getSemantics(find.byType(FlowBackButton));
    expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
  });
}
