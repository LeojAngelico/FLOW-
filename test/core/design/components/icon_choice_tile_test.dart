import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/icon_choice_tile.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpFlowWidget(
      tester,
      IconChoiceTile(label: 'Warm', level: 2, selected: false, onTap: () {}),
    );

    expect(find.text('Warm'), findsOneWidget);
  });

  testWidgets('is 104dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 154,
        child: IconChoiceTile(
          label: 'Warm',
          level: 2,
          selected: false,
          onTap: () {},
        ),
      ),
    );

    expect(tester.getSize(find.byType(IconChoiceTile)).height, 104);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      IconChoiceTile(
        label: 'Warm',
        level: 2,
        selected: false,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(IconChoiceTile));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing at every level 1-4', (tester) async {
    for (final level in [1, 2, 3, 4]) {
      await pumpFlowWidget(
        tester,
        IconChoiceTile(
          label: 'Level $level',
          level: level,
          selected: false,
          onTap: () {},
        ),
      );
      expect(find.text('Level $level'), findsOneWidget);
    }
  });

  testWidgets('renders without throwing when selected', (tester) async {
    await pumpFlowWidget(
      tester,
      IconChoiceTile(label: 'Warm', level: 2, selected: true, onTap: () {}),
    );

    expect(find.text('Warm'), findsOneWidget);
  });

  testWidgets('selected badge renders visibly without overflowing the tile', (
    tester,
  ) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 154,
        child: IconChoiceTile(
          label: 'Warm',
          level: 2,
          selected: true,
          onTap: () {},
        ),
      ),
    );

    // The 104dp height must hold even with the selected badge overlaid,
    // guarding against a regression to the original overflow bug.
    expect(tester.getSize(find.byType(IconChoiceTile)).height, 104);

    // The badge is the sole Positioned child of the tile's Stack — assert
    // it is actually present and rendered at its intended 22x22 size,
    // rather than just checking the label still renders.
    final badgeFinder = find.byType(Positioned);
    expect(badgeFinder, findsOneWidget);
    expect(tester.getSize(badgeFinder), const Size(22, 22));
  });
}
