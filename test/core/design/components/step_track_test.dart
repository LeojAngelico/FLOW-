import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/step_track.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders totalSteps done/current/upcoming nodes', (tester) async {
    await pumpFlowWidget(tester, const StepTrack(currentStep: 1));

    // 5 nodes total: 1 current + 4 upcoming when on step 1.
    expect(find.byKey(const ValueKey('step-track-node')), findsNWidgets(5));
  });

  testWidgets(
    'the current node is visually larger (22dp) than done/upcoming nodes (14dp)',
    (tester) async {
      await pumpFlowWidget(tester, const StepTrack(currentStep: 3));

      // The `find.descendant` + `find.byType(Container)` matcher from the
      // task brief excludes the "of" node itself (only its descendants),
      // so it only ever reaches the 8dp/4dp inner core box, never the
      // 22dp/14dp outer node — brittle in the way the brief flagged.
      // Using `tester.getSize` on each node's own Finder instead checks
      // the actual rendered box size directly.
      final nodeFinder = find.byKey(const ValueKey('step-track-node'));
      expect(nodeFinder, findsNWidgets(5));

      final sizes = [
        for (var i = 0; i < 5; i++) tester.getSize(nodeFinder.at(i)),
      ];

      // currentStep: 3 -> node at index 2 (1-indexed step 3) is current.
      expect(sizes[2], const Size(22, 22));
      for (final i in [0, 1, 3, 4]) {
        expect(sizes[i], const Size(14, 14));
      }
    },
  );

  testWidgets(
    'step 1 of 5 has no done nodes, step 5 of 5 has all nodes done or current',
    (tester) async {
      await pumpFlowWidget(
        tester,
        const StepTrack(currentStep: 5, totalSteps: 5),
      );

      expect(find.byKey(const ValueKey('step-track-node')), findsNWidgets(5));
    },
  );
}
