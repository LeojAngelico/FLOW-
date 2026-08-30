import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/setting_row.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the label and value', (tester) async {
    await pumpFlowWidget(
      tester,
      SettingRow(label: 'Start', value: '08:00', onTap: () {}),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
  });

  testWidgets('is 56dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: SettingRow(label: 'Start', value: '08:00', onTap: () {}),
      ),
    );

    expect(tester.getSize(find.byType(SettingRow)).height, 56);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      SettingRow(label: 'Start', value: '08:00', onTap: () => tapped = true),
    );

    await tester.tap(find.byType(SettingRow));
    expect(tapped, isTrue);
  });
}
