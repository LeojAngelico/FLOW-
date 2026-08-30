import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_text_field.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('is 56dp tall', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(
      tester,
      SizedBox(width: 328, child: FlowTextField(controller: controller)),
    );

    expect(tester.getSize(find.byType(FlowTextField)).height, 56);
  });

  testWidgets('typing updates the controller and calls onChanged', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? changed;

    await pumpFlowWidget(
      tester,
      FlowTextField(controller: controller, onChanged: (v) => changed = v),
    );

    await tester.enterText(find.byType(FlowTextField), 'Alex');
    expect(controller.text, 'Alex');
    expect(changed, 'Alex');
  });

  testWidgets('shows the error message below the field when errorText is set', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(
      tester,
      FlowTextField(
        controller: controller,
        errorText: 'Age must be between 9 and 120.',
      ),
    );

    expect(find.text('Age must be between 9 and 120.'), findsOneWidget);
  });

  testWidgets('renders without an error message when errorText is null', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(tester, FlowTextField(controller: controller));

    expect(find.byType(Text), findsNothing);
  });
}
