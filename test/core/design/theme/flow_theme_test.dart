import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/theme/flow_theme.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';
import 'package:flow/core/design/tokens/flow_typography.dart';

void main() {
  test('light theme exposes FlowColors.light and FlowTypography.standard', () {
    expect(FlowTheme.light.extension<FlowColors>(), FlowColors.light);
    expect(
      FlowTheme.light.extension<FlowTypography>(),
      FlowTypography.standard,
    );
    expect(FlowTheme.light.brightness, Brightness.light);
  });

  test('dark theme exposes FlowColors.dark and FlowTypography.standard', () {
    expect(FlowTheme.dark.extension<FlowColors>(), FlowColors.dark);
    expect(FlowTheme.dark.extension<FlowTypography>(), FlowTypography.standard);
    expect(FlowTheme.dark.brightness, Brightness.dark);
  });

  test(
    'light and dark scaffold backgrounds match FlowColors backgroundPrimary',
    () {
      expect(
        FlowTheme.light.scaffoldBackgroundColor,
        FlowColors.light.backgroundPrimary,
      );
      expect(
        FlowTheme.dark.scaffoldBackgroundColor,
        FlowColors.dark.backgroundPrimary,
      );
    },
  );

  test('both themes use Material 3', () {
    expect(FlowTheme.light.useMaterial3, isTrue);
    expect(FlowTheme.dark.useMaterial3, isTrue);
  });
}
