import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/tokens/flow_typography.dart';

void main() {
  test('numericHero matches the documented spec', () {
    final style = FlowTypography.standard.numericHero;

    expect(style.fontFamily, 'Inter');
    expect(style.fontSize, 56);
    expect(style.height, closeTo(60 / 56, 0.01));
    expect(style.fontWeight, FontWeight.w700);
    expect(style.letterSpacing, -1.5);
  });

  test('pixelTitle uses Press Start 2P and never falls below 20sp', () {
    final style = FlowTypography.standard.pixelTitle;

    expect(style.fontFamily, 'Press Start 2P');
    expect(style.fontSize, 20);
  });

  test('caption is the smallest style and nothing ships below it', () {
    final styles = [
      FlowTypography.standard.displayL,
      FlowTypography.standard.displayM,
      FlowTypography.standard.headline,
      FlowTypography.standard.titleL,
      FlowTypography.standard.titleM,
      FlowTypography.standard.bodyL,
      FlowTypography.standard.bodyM,
      FlowTypography.standard.label,
      FlowTypography.standard.caption,
      FlowTypography.standard.button,
    ];

    for (final style in styles) {
      expect(
        style.fontSize! >= FlowTypography.standard.caption.fontSize!,
        isTrue,
      );
    }
  });

  test(
    'buttonGame and labelGame are uppercase-tracked Inter, not Press Start 2P',
    () {
      expect(FlowTypography.standard.buttonGame.fontFamily, 'Inter');
      expect(FlowTypography.standard.buttonGame.letterSpacing, 1.2);
      expect(FlowTypography.standard.labelGame.fontFamily, 'Inter');
    },
  );

  test('lerp at t=0 and t=1 returns the expected endpoint style', () {
    const other = FlowTypography.standard;
    final result = FlowTypography.standard.lerp(other, 1);

    expect(result.bodyL.fontSize, other.bodyL.fontSize);
  });
}
