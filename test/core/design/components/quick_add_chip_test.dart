import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/quick_add_chip.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the amount in millilitres', (tester) async {
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 350, selected: false, onTap: () {}),
    );

    expect(find.text('350 ML'), findsOneWidget);
  });

  testWidgets('is 56dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 350, selected: false, onTap: () {}),
    );

    expect(tester.getSize(find.byType(QuickAddChip)).height, 56);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 350, selected: false, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(QuickAddChip));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when selected', (tester) async {
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 500, selected: true, onTap: () {}),
    );

    expect(find.text('500 ML'), findsOneWidget);
  });
}
