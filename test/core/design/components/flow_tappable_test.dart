import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_tappable.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('exposes button: true semantics', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTappable(onTap: () {}, child: const Text('Tap me')),
    );

    final data = tester.getSemantics(find.byType(FlowTappable));
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
  });

  testWidgets('an explicit label does not duplicate a visible Text label', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      FlowTappable(onTap: () {}, child: const Text('Tap me')),
    );

    final data = tester.getSemantics(find.byType(FlowTappable));
    expect(data.label, 'Tap me');
  });

  testWidgets('label is used verbatim when there is no visible text', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      FlowTappable(
        onTap: () {},
        label: 'Icon-only action',
        child: const Icon(Icons.star),
      ),
    );

    final data = tester.getSemantics(find.byType(FlowTappable));
    expect(data.label, 'Icon-only action');
  });

  testWidgets('selected: true is exposed as isSelected', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTappable(onTap: () {}, selected: true, child: const Text('x')),
    );

    final data = tester.getSemantics(find.byType(FlowTappable));
    expect(data.hasFlag(SemanticsFlag.isSelected), isTrue);
  });

  testWidgets('checked: true is exposed as hasCheckedState + isChecked', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      FlowTappable(onTap: () {}, checked: true, child: const Text('x')),
    );

    final data = tester.getSemantics(find.byType(FlowTappable));
    expect(data.hasFlag(SemanticsFlag.hasCheckedState), isTrue);
    expect(data.hasFlag(SemanticsFlag.isChecked), isTrue);
  });

  testWidgets(
    'enabled: false disables tap handling and is reported as disabled',
    (tester) async {
      var tapped = false;
      await pumpFlowWidget(
        tester,
        FlowTappable(
          onTap: () => tapped = true,
          enabled: false,
          child: const Text('x'),
        ),
      );

      await tester.tap(find.byType(FlowTappable), warnIfMissed: false);
      expect(tapped, isFalse);

      final data = tester.getSemantics(find.byType(FlowTappable));
      expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
    },
  );

  testWidgets('onTap fires when enabled', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      FlowTappable(onTap: () => tapped = true, child: const Text('x')),
    );

    await tester.tap(find.byType(FlowTappable));
    expect(tapped, isTrue);
  });
}
