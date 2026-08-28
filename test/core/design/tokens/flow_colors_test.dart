import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

void main() {
  test('light brand and semantic tokens match the verified hex values', () {
    const c = FlowColors.light;

    expect(c.brandPrimary, const Color(0xFF2FB6F0));
    expect(c.brandPrimaryPressed, const Color(0xFF085A82));
    expect(c.backgroundPrimary, const Color(0xFFFFFFFF));
    expect(c.textPrimary, const Color(0xFF101A2E));
    expect(c.error, const Color(0xFFC22A2E));
  });

  test('dark brand and semantic tokens match the verified hex values', () {
    const c = FlowColors.dark;

    expect(c.backgroundPrimary, const Color(0xFF101A33));
    expect(c.textPrimary, const Color(0xFFEAF2FF));
    expect(c.brandPrimary, const Color(0xFF2FB6F0));
  });

  test(
    'game-surface tokens are genuinely theme-dependent (Figma-verified correction)',
    () {
      expect(FlowColors.light.panelDeep, const Color(0xFF085A82));
      expect(FlowColors.dark.panelDeep, const Color(0xFF06405E));

      expect(FlowColors.light.trackDark, const Color(0xFF143A52));
      expect(FlowColors.dark.trackDark, const Color(0xFF0C2436));

      expect(FlowColors.light.canvasGame, const Color(0xFFE4F5FD));
      expect(FlowColors.dark.canvasGame, FlowColors.dark.backgroundPrimary);
    },
  );

  test('frame tokens are theme-independent', () {
    expect(FlowColors.light.frameInk, FlowColors.dark.frameInk);
    expect(FlowColors.light.frameDepth, FlowColors.dark.frameDepth);
  });

  test('copyWith overrides only the requested field', () {
    final overridden = FlowColors.light.copyWith(brandPrimary: Colors.red);

    expect(overridden.brandPrimary, Colors.red);
    expect(overridden.textPrimary, FlowColors.light.textPrimary);
  });

  test('lerp at t=0 returns this and at t=1 returns other', () {
    final result0 = FlowColors.light.lerp(FlowColors.dark, 0);
    final result1 = FlowColors.light.lerp(FlowColors.dark, 1);

    expect(result0.backgroundPrimary, FlowColors.light.backgroundPrimary);
    expect(result1.backgroundPrimary, FlowColors.dark.backgroundPrimary);
  });

  test('a FlowColors extension is retrievable from a ThemeData', () {
    final theme = ThemeData(extensions: const [FlowColors.light]);

    expect(theme.extension<FlowColors>(), FlowColors.light);
  });
}
