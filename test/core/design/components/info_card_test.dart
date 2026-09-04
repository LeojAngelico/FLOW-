import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/info_card.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its message', (tester) async {
    await pumpFlowWidget(
      tester,
      const InfoCard(message: 'Hydration needs vary from person to person.'),
    );

    expect(
      find.text('Hydration needs vary from person to person.'),
      findsOneWidget,
    );
  });

  testWidgets('Info kind uses infoSurface background', (tester) async {
    await pumpFlowWidget(
      tester,
      const InfoCard(message: 'msg', kind: InfoCardKind.info),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, FlowColors.light.infoSurface);
  });

  testWidgets(
    'Caution kind uses warningSurface background with legible warning text (bug fix, not the raw Figma export)',
    (tester) async {
      await pumpFlowWidget(
        tester,
        const InfoCard(
          message: "That's quite high.",
          kind: InfoCardKind.caution,
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, FlowColors.light.warningSurface);

      final text = tester.widget<Text>(find.text("That's quite high."));
      expect(text.style!.color, FlowColors.light.warning);
      expect(text.style!.color, isNot(decoration.color));
    },
  );
}
