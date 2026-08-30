import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_text_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label without uppercasing', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'How we calculated this', onPressed: () {}),
    );

    expect(find.text('How we calculated this'), findsOneWidget);
  });

  testWidgets('is 48dp tall regardless of label length', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'Skip', onPressed: () {}),
    );

    expect(tester.getSize(find.byType(FlowTextButton)).height, 48);
  });

  testWidgets('shows the leading icon by default', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'How we calculated this', onPressed: () {}),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets(
    'hides the leading icon when showIcon is false (the Skip/NoIcon variant)',
    (tester) async {
      await pumpFlowWidget(
        tester,
        FlowTextButton(label: 'Skip', onPressed: () {}, showIcon: false),
      );

      expect(find.byType(SvgPicture), findsNothing);
    },
  );

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      FlowTextButton(
        label: 'Skip',
        onPressed: () => tapped = true,
        showIcon: false,
      ),
    );

    await tester.tap(find.byType(FlowTextButton));
    expect(tapped, isTrue);
  });
}
