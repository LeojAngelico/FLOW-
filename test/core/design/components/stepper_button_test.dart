import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/stepper_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('a single tap calls onStep exactly once', (tester) async {
    var steps = 0;
    await pumpFlowWidget(
      tester,
      StepperButton(direction: StepDirection.increment, onStep: () => steps++),
    );

    await tester.tap(find.byType(StepperButton));

    expect(steps, 1);
  });

  testWidgets('renders the "+" glyph for increment and "−" for decrement', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      StepperButton(direction: StepDirection.increment, onStep: () {}),
    );
    expect(find.text('+'), findsOneWidget);

    await pumpFlowWidget(
      tester,
      StepperButton(direction: StepDirection.decrement, onStep: () {}),
    );
    expect(find.text('−'), findsOneWidget);
  });

  testWidgets('is 64dp square', (tester) async {
    await pumpFlowWidget(
      tester,
      StepperButton(direction: StepDirection.increment, onStep: () {}),
    );

    expect(tester.getSize(find.byType(StepperButton)), const Size(64, 64));
  });

  testWidgets('enabled: false disables both the tap and the semantics '
      'action', (tester) async {
    var steps = 0;
    await pumpFlowWidget(
      tester,
      StepperButton(
        direction: StepDirection.increment,
        onStep: () => steps++,
        enabled: false,
      ),
    );

    await tester.tap(find.byType(StepperButton), warnIfMissed: false);

    expect(steps, 0);
    final semantics = tester.getSemantics(find.byType(StepperButton));
    expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
  });

  testWidgets('holding past the initial delay auto-repeats onStep every '
      '150ms, and releasing stops it', (tester) async {
    var steps = 0;
    await pumpFlowWidget(
      tester,
      StepperButton(direction: StepDirection.increment, onStep: () => steps++),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(StepperButton)),
    );

    // Past the tap-recognizer's own resolution delay plus the
    // component's 400ms initial repeat delay.
    await tester.pump(const Duration(milliseconds: 700));
    expect(steps, greaterThanOrEqualTo(1));

    final afterInitialDelay = steps;
    await tester.pump(const Duration(milliseconds: 150));
    expect(steps, afterInitialDelay + 1);

    await tester.pump(const Duration(milliseconds: 150));
    expect(steps, afterInitialDelay + 2);

    await gesture.up();
    final afterRelease = steps;
    await tester.pump(const Duration(milliseconds: 500));

    expect(steps, afterRelease);
  });
}
