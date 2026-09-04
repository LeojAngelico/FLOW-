import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/choice_card.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders title and description', (tester) async {
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'Some walking, light movement most days',
        barsFilled: 2,
        selected: false,
        onTap: () {},
      ),
    );

    expect(find.text('Lightly active'), findsOneWidget);
    expect(find.text('Some walking, light movement most days'), findsOneWidget);
  });

  testWidgets('renders exactly 5 bars in the leading bar-meter', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'desc',
        barsFilled: 2,
        selected: false,
        onTap: () {},
      ),
    );

    expect(find.byKey(const ValueKey('choice-card-bar')), findsNWidgets(5));
  });

  testWidgets('is at least 76dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: ChoiceCard(
          title: 'Lightly active',
          description: 'Some walking, light movement most days',
          barsFilled: 2,
          selected: false,
          onTap: () {},
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(ChoiceCard)).height,
      greaterThanOrEqualTo(76),
    );
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'desc',
        barsFilled: 2,
        selected: false,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(ChoiceCard));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when selected', (tester) async {
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'desc',
        barsFilled: 2,
        selected: true,
        onTap: () {},
      ),
    );

    expect(find.text('Lightly active'), findsOneWidget);
  });
}
