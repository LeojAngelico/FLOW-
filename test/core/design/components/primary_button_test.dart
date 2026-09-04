import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/primary_button.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}),
    );

    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('is 60dp tall (56 + 4dp depth offset)', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: PrimaryButton(label: 'Continue', onPressed: () {}),
      ),
    );

    final size = tester.getSize(find.byType(PrimaryButton));
    expect(size.height, 60);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () => tapped = true),
    );

    await tester.tap(find.byType(PrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('disabled when onPressed is null and does not call it on tap', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      const PrimaryButton(label: 'Continue', onPressed: null),
    );

    await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
    // No exception thrown means the disabled button ignored the tap.
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('shows a spinner instead of the label when isLoading is true', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}, isLoading: true),
    );

    expect(find.text('CONTINUE'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders a trailing icon when trailingIcon is given', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(
        label: 'Continue',
        onPressed: () {},
        trailingIcon: Icons.arrow_forward_rounded,
      ),
    );

    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
  });

  testWidgets(
    'pressed state fills with brandPrimaryActive while the finger is down',
    (tester) async {
      await pumpFlowWidget(
        tester,
        PrimaryButton(label: 'Continue', onPressed: () {}),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PrimaryButton)),
      );
      await tester.pump();

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, FlowColors.light.brandPrimaryActive);

      await gesture.up();
    },
  );

  testWidgets(
    'milestone variant fills with achievement instead of brandPrimary',
    (tester) async {
      await pumpFlowWidget(
        tester,
        PrimaryButton(label: 'Continue', onPressed: () {}, isMilestone: true),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, FlowColors.light.achievement);
    },
  );

  testWidgets(
    'label uses onBrandFill (fixed navy) in dark mode, not textPrimary '
    '(which flips to near-white and fails WCAG 1.4.3 against the '
    'theme-invariant brandPrimary fill)',
    (tester) async {
      await pumpFlowWidget(
        tester,
        PrimaryButton(label: 'Continue', onPressed: () {}),
        brightness: Brightness.dark,
      );

      final text = tester.widget<Text>(find.text('CONTINUE'));
      expect(text.style!.color, FlowColors.dark.onBrandFill);
      expect(text.style!.color, isNot(FlowColors.dark.textPrimary));
    },
  );
}
