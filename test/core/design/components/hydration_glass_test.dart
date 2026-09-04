import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/hydration_glass.dart';
import 'package:flow/core/design/tokens/flow_motion.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  double heightFactorOf(WidgetTester tester) {
    return tester
        .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .heightFactor!;
  }

  group('fill height', () {
    testWidgets('0% at currentMl 0', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 0, targetMl: 2000),
      );

      expect(heightFactorOf(tester), 0.0);
    });

    testWidgets('50% at half the target', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 1000, targetMl: 2000),
      );

      expect(heightFactorOf(tester), 0.5);
    });

    testWidgets('100% exactly at the target', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 2000, targetMl: 2000),
      );

      expect(heightFactorOf(tester), 1.0);
    });

    testWidgets('caps at 100% once past the target (150%) -- FR-033: '
        'the graphic must never overflow the glass', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 3000, targetMl: 2000),
      );

      expect(heightFactorOf(tester), 1.0);
    });

    testWidgets('renders an empty glass for a non-positive target instead '
        'of dividing by zero', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 500, targetMl: 0),
      );

      expect(heightFactorOf(tester), 0.0);
    });
  });

  group('reduceMotion collapses a retarget to an instant jump', () {
    testWidgets('with reduceMotion, the fill has fully reached the new '
        'target after FlowMotion.instant elapses', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(
          currentMl: 0,
          targetMl: 1000,
          reduceMotion: true,
        ),
      );
      await pumpFlowWidget(
        tester,
        const HydrationGlass(
          currentMl: 500,
          targetMl: 1000,
          reduceMotion: true,
        ),
      );

      await tester.pump(FlowMotion.instant);

      expect(heightFactorOf(tester), 0.5);
    });

    testWidgets('without reduceMotion, the same elapsed time is still '
        'mid-animation (FlowMotion.slow is 450ms, well past the 100ms '
        'reduceMotion duration)', (tester) async {
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 0, targetMl: 1000),
      );
      await pumpFlowWidget(
        tester,
        const HydrationGlass(currentMl: 500, targetMl: 1000),
      );

      await tester.pump(FlowMotion.instant);

      expect(heightFactorOf(tester), lessThan(0.5));
    });
  });

  testWidgets('renders exactly one hydration-glass node', (tester) async {
    await pumpFlowWidget(
      tester,
      const HydrationGlass(currentMl: 500, targetMl: 2000),
    );

    expect(find.byKey(const ValueKey('hydration-glass')), findsOneWidget);
  });
}
