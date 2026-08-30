import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_slider.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the min and max range labels', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowSlider(
        value: 68,
        min: 25,
        max: 250,
        onChanged: (_) {},
        rangeLabelBuilder: (v) => '${v.round()} kg',
      ),
    );

    expect(find.text('25 kg'), findsOneWidget);
    expect(find.text('250 kg'), findsOneWidget);
  });

  testWidgets('exposes a Semantics value for screen readers stepping by 1', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      FlowSlider(
        value: 68,
        min: 25,
        max: 250,
        onChanged: (_) {},
        rangeLabelBuilder: (v) => '${v.round()} kg',
      ),
    );

    final semantics = tester.getSemantics(find.byType(Slider));
    expect(semantics.value, '68 kilograms');
  });

  testWidgets('dragging the underlying Slider calls onChanged', (tester) async {
    double? changed;
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: FlowSlider(
          value: 68,
          min: 25,
          max: 250,
          onChanged: (v) => changed = v,
          rangeLabelBuilder: (v) => '${v.round()} kg',
        ),
      ),
    );

    await tester.drag(find.byType(Slider), const Offset(50, 0));
    expect(changed, isNotNull);
  });
}
