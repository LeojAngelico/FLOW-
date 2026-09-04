import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_frame_box.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its child', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowFrameBox(
        fill: FlowColors.light.brandPrimary,
        frameInk: FlowColors.light.frameInk,
        child: const Text('inside'),
      ),
    );

    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('with depth > 0, occupies extra height equal to the depth', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        height: 60,
        child: FlowFrameBox(
          fill: FlowColors.light.brandPrimary,
          frameInk: FlowColors.light.frameInk,
          depth: 4,
          depthColor: FlowColors.light.frameDepth,
          child: const SizedBox(height: 56),
        ),
      ),
    );

    expect(find.byType(FlowFrameBox), findsOneWidget);
    final size = tester.getSize(find.byType(FlowFrameBox));
    expect(size.height, 60);
  });

  testWidgets(
    'with depth == 0, occupies exactly the child height (pressed state)',
    (tester) async {
      await pumpFlowWidget(
        tester,
        FlowFrameBox(
          fill: FlowColors.light.brandPrimary,
          frameInk: FlowColors.light.frameInk,
          child: const SizedBox(height: 56, width: 200),
        ),
      );

      final size = tester.getSize(find.byType(FlowFrameBox));
      expect(size.height, 56);
    },
  );
}
