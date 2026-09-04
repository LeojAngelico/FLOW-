import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/pillar.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders title, description, and its icon', (tester) async {
    await pumpFlowWidget(
      tester,
      const Pillar(
        iconAsset: 'assets/icons/onboarding/icon-droplet.svg',
        title: 'Hydrate',
        description: 'Know your daily target and track your water.',
      ),
    );

    expect(find.text('Hydrate'), findsOneWidget);
    expect(
      find.text('Know your daily target and track your water.'),
      findsOneWidget,
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('is at least 76dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: const Pillar(
          iconAsset: 'assets/icons/onboarding/icon-droplet.svg',
          title: 'Hydrate',
          description: 'Know your daily target and track your water.',
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(Pillar)).height,
      greaterThanOrEqualTo(76),
    );
  });
}
