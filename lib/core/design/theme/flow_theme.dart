import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

class FlowTheme {
  FlowTheme._();

  static final ThemeData light = _build(FlowColors.light, Brightness.light);
  static final ThemeData dark = _build(FlowColors.dark, Brightness.dark);

  static ThemeData _build(FlowColors colors, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.brandPrimary,
      onPrimary: colors.textPrimary,
      secondary: colors.brandSecondary,
      onSecondary: colors.textPrimary,
      error: colors.error,
      onError: colors.backgroundPrimary,
      surface: colors.surfacePrimary,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundPrimary,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        titleTextStyle: FlowTypography.standard.titleL.copyWith(
          color: colors.textPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: FlowTypography.standard.displayL.copyWith(
          color: colors.textPrimary,
        ),
        displayMedium: FlowTypography.standard.displayM.copyWith(
          color: colors.textPrimary,
        ),
        headlineMedium: FlowTypography.standard.headline.copyWith(
          color: colors.textPrimary,
        ),
        titleLarge: FlowTypography.standard.titleL.copyWith(
          color: colors.textPrimary,
        ),
        titleMedium: FlowTypography.standard.titleM.copyWith(
          color: colors.textPrimary,
        ),
        bodyLarge: FlowTypography.standard.bodyL.copyWith(
          color: colors.textPrimary,
        ),
        bodyMedium: FlowTypography.standard.bodyM.copyWith(
          color: colors.textSecondary,
        ),
        labelLarge: FlowTypography.standard.button.copyWith(
          color: colors.textPrimary,
        ),
        labelSmall: FlowTypography.standard.caption.copyWith(
          color: colors.textSecondary,
        ),
      ),
      extensions: [colors, FlowTypography.standard],
    );
  }
}
