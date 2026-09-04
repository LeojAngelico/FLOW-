import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/check_row.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: false, onChanged: (_) {}),
    );

    expect(find.text("I'm pregnant"), findsOneWidget);
  });

  testWidgets('is 48dp tall (full-row hit target)', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: CheckRow(
          label: "I'm pregnant",
          checked: false,
          onChanged: (_) {},
        ),
      ),
    );

    expect(tester.getSize(find.byType(CheckRow)).height, 48);
  });

  testWidgets('shows the check icon only when checked', (tester) async {
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: false, onChanged: (_) {}),
    );
    expect(find.byType(SvgPicture), findsNothing);

    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: true, onChanged: (_) {}),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('tapping toggles via onChanged with the opposite value', (
    tester,
  ) async {
    bool? newValue;
    await pumpFlowWidget(
      tester,
      CheckRow(
        label: "I'm pregnant",
        checked: false,
        onChanged: (v) => newValue = v,
      ),
    );

    await tester.tap(find.byType(CheckRow));
    expect(newValue, isTrue);
  });

  testWidgets('exposes true checkbox Semantics', (tester) async {
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: true, onChanged: (_) {}),
    );

    final semantics = tester.getSemantics(find.byType(CheckRow));
    expect(semantics.hasFlag(SemanticsFlag.hasCheckedState), isTrue);
    expect(semantics.hasFlag(SemanticsFlag.isChecked), isTrue);
  });
}
