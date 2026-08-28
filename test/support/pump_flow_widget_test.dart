// test/support/pump_flow_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_flow_widget.dart';

void main() {
  testWidgets(
    'pumpFlowWidget renders the given child inside a themed MaterialApp',
    (tester) async {
      await pumpFlowWidget(tester, const Text('hello'));

      expect(find.text('hello'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );

  testWidgets('pumpFlowWidget honors the brightness parameter', (tester) async {
    await pumpFlowWidget(tester, const SizedBox(), brightness: Brightness.dark);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.brightness, Brightness.dark);
  });
}
