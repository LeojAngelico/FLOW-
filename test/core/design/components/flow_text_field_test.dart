import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets(
    'inputFormatters defaults to null, and an unset keyboardType falls '
    'through to TextField\'s own single-line default (TextInputType.text) '
    'rather than FlowTextField forcing a value of its own, so an '
    'existing caller that does not pass either keeps its prior '
    'behaviour unchanged',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpFlowWidget(tester, FlowTextField(controller: controller));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.text);
      expect(textField.inputFormatters, isNull);
    },
  );

  testWidgets('passes keyboardType and inputFormatters straight through to the '
      'underlying TextField', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(
      tester,
      FlowTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.number);
    expect(textField.inputFormatters, [FilteringTextInputFormatter.digitsOnly]);
  });

  testWidgets(
    'a digits-only inputFormatter actually filters non-digit characters '
    'as they are typed, not just an unused constructor parameter',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pumpFlowWidget(
        tester,
        FlowTextField(
          controller: controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );

      await tester.enterText(find.byType(FlowTextField), '5a0b');

      expect(controller.text, '50');
    },
  );
}
