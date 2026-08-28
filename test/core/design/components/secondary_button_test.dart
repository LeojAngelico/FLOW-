import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/secondary_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its uppercased label', (tester) async {
    await pumpFlowWidget(
      tester,
      SecondaryButton(label: 'Adjust manually', onPressed: () {}),
    );

    expect(find.text('ADJUST MANUALLY'), findsOneWidget);
  });

  testWidgets('is 52dp tall — 4dp shorter than PrimaryButton', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: SecondaryButton(label: 'Adjust manually', onPressed: () {}),
      ),
    );

    expect(tester.getSize(find.byType(SecondaryButton)).height, 52);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      SecondaryButton(label: 'Adjust manually', onPressed: () => tapped = true),
    );

    await tester.tap(find.byType(SecondaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when disabled', (tester) async {
    await pumpFlowWidget(
      tester,
      const SecondaryButton(label: 'Adjust manually', onPressed: null),
    );

    expect(find.text('ADJUST MANUALLY'), findsOneWidget);
  });
}
