import 'package:flutter/material.dart';

/// Semantic colors that Material 3's [ColorScheme] doesn't define.
///
/// Everything else in the kit reads colors from `Theme.of(context)`.
/// This exists only because M3 has no built-in "warning" role —
/// keep it to genuine gaps like this rather than a general palette.
class AppColors {
  AppColors._();

  static const Color warning = Color(0xFFB25E00);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDDB3);
  static const Color onWarningContainer = Color(0xFF3D2600);
}
