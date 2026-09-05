import 'dart:ui';

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
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
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

  testWidgets(
    'a mid-hold rebuild to enabled: false stops the auto-repeat timer '
    '(Manual QA item 8 -- e.g. hitting the 2,000ml cap while held)',
    (tester) async {
      var steps = 0;
      await pumpFlowWidget(
        tester,
        StepperButton(
          direction: StepDirection.increment,
          onStep: () => steps++,
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepperButton)),
      );

      // Past the initial repeat delay -- the hold is now auto-repeating.
      await tester.pump(const Duration(milliseconds: 700));
      expect(steps, greaterThanOrEqualTo(1));

      // Simulate the bound being hit mid-hold: the parent rebuilds this
      // button disabled without the gesture ever completing.
      // `FlowTappable` nulls its gesture callbacks when `enabled` goes
      // false, so the recognizer is torn down without ever calling
      // onTapUp/onTapCancel -- the fix under test must stop the repeat
      // timer some other way.
      await pumpFlowWidget(
        tester,
        StepperButton(
          direction: StepDirection.increment,
          onStep: () => steps++,
          enabled: false,
        ),
      );

      final afterDisable = steps;
      await tester.pump(const Duration(milliseconds: 500));

      expect(steps, afterDisable);

      // Releasing the now-orphaned pointer must not throw.
      await gesture.up();
    },
  );
}
