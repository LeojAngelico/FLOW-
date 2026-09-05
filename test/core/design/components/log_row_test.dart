import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/log_row.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the amount through the shared volume formatter', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      LogRow(amountMl: 350, occurredAt: DateTime(2026, 1, 1, 8, 30)),
    );

    expect(find.text('350 ml'), findsOneWidget);
  });

  testWidgets('an amount at or above 1000ml renders in litres, matching '
      'formatVolumeMl', (tester) async {
    await pumpFlowWidget(
      tester,
      LogRow(amountMl: 1250, occurredAt: DateTime(2026, 1, 1, 8, 30)),
    );

    expect(find.text('1.25 L'), findsOneWidget);
  });

  testWidgets('is 56dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      LogRow(amountMl: 350, occurredAt: DateTime(2026, 1, 1, 8, 30)),
    );

    expect(tester.getSize(find.byType(LogRow)).height, 56);
  });

  testWidgets('has no overflow menu -- undo/delete/edit ship with '
      'gamification, not this pass', (tester) async {
    await pumpFlowWidget(
      tester,
      LogRow(amountMl: 350, occurredAt: DateTime(2026, 1, 1, 8, 30)),
    );

    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.byType(PopupMenuButton), findsNothing);
  });

  testWidgets('exposes the amount and time as a single merged semantics '
      'node', (tester) async {
    await pumpFlowWidget(
      tester,
      LogRow(amountMl: 350, occurredAt: DateTime(2026, 1, 1, 8, 30)),
    );

    final semantics = tester.getSemantics(find.byType(LogRow));
    expect(semantics.label, contains('350 ml'));
  });
}
