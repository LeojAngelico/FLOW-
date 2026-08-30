import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/segmented_choice.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders a label per option', (tester) async {
    await pumpFlowWidget(
      tester,
      SegmentedChoice<String>(
        options: const ['KG', 'LB'],
        selected: 'KG',
        labelBuilder: (o) => o,
        onChanged: (_) {},
      ),
    );

    expect(find.text('KG'), findsOneWidget);
    expect(find.text('LB'), findsOneWidget);
  });

  testWidgets(
    'the 2-segment /Unit shell is 56dp tall (48dp segment + 4dp padding each side)',
    (tester) async {
      await pumpFlowWidget(
        tester,
        SizedBox(
          width: 168,
          child: SegmentedChoice<String>(
            options: const ['KG', 'LB'],
            selected: 'KG',
            labelBuilder: (o) => o,
            onChanged: (_) {},
          ),
        ),
      );

      expect(tester.getSize(find.byType(SegmentedChoice<String>)).height, 56);
    },
  );

  testWidgets(
    'the 3-segment /Sex shell is 64dp tall when segmentHeight is 56',
    (tester) async {
      await pumpFlowWidget(
        tester,
        SizedBox(
          width: 328,
          child: SegmentedChoice<String>(
            options: const ['Female', 'Male', 'Prefer not to say'],
            selected: 'Female',
            labelBuilder: (o) => o,
            onChanged: (_) {},
            segmentHeight: 56,
          ),
        ),
      );

      expect(tester.getSize(find.byType(SegmentedChoice<String>)).height, 64);
    },
  );

  testWidgets(
    'tapping an unselected segment calls onChanged with that option',
    (tester) async {
      String? changedTo;
      await pumpFlowWidget(
        tester,
        SegmentedChoice<String>(
          options: const ['KG', 'LB'],
          selected: 'KG',
          labelBuilder: (o) => o,
          onChanged: (value) => changedTo = value,
        ),
      );

      await tester.tap(find.text('LB'));
      expect(changedTo, 'LB');
    },
  );
}
