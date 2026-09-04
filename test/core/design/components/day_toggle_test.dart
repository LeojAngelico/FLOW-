import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/day_toggle.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the day letter', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: true, onTap: () {}),
    );

    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('is a 40dp circle', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: true, onTap: () {}),
    );

    expect(tester.getSize(find.byType(DayToggle)), const Size(40, 40));
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: false, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(DayToggle));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when off', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: false, onTap: () {}),
    );

    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('selected label uses onBrandFill (fixed navy) in dark mode, not '
      'textPrimary (which flips to near-white and fails WCAG 1.4.3 '
      'against the theme-invariant brandPrimary fill)', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: true, onTap: () {}),
      brightness: Brightness.dark,
    );

    final text = tester.widget<Text>(find.text('M'));
    expect(text.style!.color, FlowColors.dark.onBrandFill);
    expect(text.style!.color, isNot(FlowColors.dark.textPrimary));
  });
}
