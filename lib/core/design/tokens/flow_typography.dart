import 'package:flutter/material.dart';

/// Every type style from 06-design-system.md §3, verified against the
/// Figma file's bound text-style variables. `pixelTitle` wraps to a
/// maximum of 3 lines (the v3.1 changelog correction — the written
/// table's "max two lines" is stale); enforcing the line cap is the
/// consuming widget's responsibility, not this style object's.
class FlowTypography extends ThemeExtension<FlowTypography> {
  const FlowTypography({
    required this.numericHero,
    required this.numericL,
    required this.pixelDisplay,
    required this.pixelHero,
    required this.pixelTitle,
    required this.pixelUnit,
    required this.labelGame,
    required this.buttonGame,
    required this.displayL,
    required this.displayM,
    required this.headline,
    required this.titleL,
    required this.titleM,
    required this.bodyL,
    required this.bodyM,
    required this.label,
    required this.caption,
    required this.button,
  });

  final TextStyle numericHero;
  final TextStyle numericL;
  final TextStyle pixelDisplay;
  final TextStyle pixelHero;
  final TextStyle pixelTitle;
  final TextStyle pixelUnit;
  final TextStyle labelGame;
  final TextStyle buttonGame;
  final TextStyle displayL;
  final TextStyle displayM;
  final TextStyle headline;
  final TextStyle titleL;
  final TextStyle titleM;
  final TextStyle bodyL;
  final TextStyle bodyM;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle button;

  static const String _inter = 'Inter';
  static const String _pixel = 'Press Start 2P';

  static const FlowTypography standard = FlowTypography(
    numericHero: TextStyle(
      fontFamily: _inter,
      fontSize: 56,
      height: 60 / 56,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    numericL: TextStyle(
      fontFamily: _inter,
      fontSize: 28,
      height: 32 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    pixelDisplay: TextStyle(
      fontFamily: _pixel,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w400,
    ),
    pixelHero: TextStyle(
      fontFamily: _pixel,
      fontSize: 40,
      height: 44 / 40,
      fontWeight: FontWeight.w400,
    ),
    pixelTitle: TextStyle(
      fontFamily: _pixel,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w400,
    ),
    pixelUnit: TextStyle(
      fontFamily: _pixel,
      fontSize: 20,
      height: 24 / 20,
      fontWeight: FontWeight.w400,
    ),
    labelGame: TextStyle(
      fontFamily: _inter,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
    buttonGame: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 20 / 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
    displayL: TextStyle(
      fontFamily: _inter,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
    displayM: TextStyle(
      fontFamily: _inter,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headline: TextStyle(
      fontFamily: _inter,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleL: TextStyle(
      fontFamily: _inter,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
    ),
    titleM: TextStyle(
      fontFamily: _inter,
      fontSize: 17,
      height: 24 / 17,
      fontWeight: FontWeight.w600,
    ),
    bodyL: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    bodyM: TextStyle(
      fontFamily: _inter,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
    ),
    label: TextStyle(
      fontFamily: _inter,
      fontSize: 13,
      height: 16 / 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
    caption: TextStyle(
      fontFamily: _inter,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
    ),
    button: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 20 / 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );

  @override
  FlowTypography copyWith({
    TextStyle? numericHero,
    TextStyle? numericL,
    TextStyle? pixelDisplay,
    TextStyle? pixelHero,
    TextStyle? pixelTitle,
    TextStyle? pixelUnit,
    TextStyle? labelGame,
    TextStyle? buttonGame,
    TextStyle? displayL,
    TextStyle? displayM,
    TextStyle? headline,
    TextStyle? titleL,
    TextStyle? titleM,
    TextStyle? bodyL,
    TextStyle? bodyM,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? button,
  }) {
    return FlowTypography(
      numericHero: numericHero ?? this.numericHero,
      numericL: numericL ?? this.numericL,
      pixelDisplay: pixelDisplay ?? this.pixelDisplay,
      pixelHero: pixelHero ?? this.pixelHero,
      pixelTitle: pixelTitle ?? this.pixelTitle,
      pixelUnit: pixelUnit ?? this.pixelUnit,
      labelGame: labelGame ?? this.labelGame,
      buttonGame: buttonGame ?? this.buttonGame,
      displayL: displayL ?? this.displayL,
      displayM: displayM ?? this.displayM,
      headline: headline ?? this.headline,
      titleL: titleL ?? this.titleL,
      titleM: titleM ?? this.titleM,
      bodyL: bodyL ?? this.bodyL,
      bodyM: bodyM ?? this.bodyM,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      button: button ?? this.button,
    );
  }

  @override
  FlowTypography lerp(ThemeExtension<FlowTypography>? other, double t) {
    if (other is! FlowTypography) {
      return this;
    }

    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;

    return FlowTypography(
      numericHero: s(numericHero, other.numericHero),
      numericL: s(numericL, other.numericL),
      pixelDisplay: s(pixelDisplay, other.pixelDisplay),
      pixelHero: s(pixelHero, other.pixelHero),
      pixelTitle: s(pixelTitle, other.pixelTitle),
      pixelUnit: s(pixelUnit, other.pixelUnit),
      labelGame: s(labelGame, other.labelGame),
      buttonGame: s(buttonGame, other.buttonGame),
      displayL: s(displayL, other.displayL),
      displayM: s(displayM, other.displayM),
      headline: s(headline, other.headline),
      titleL: s(titleL, other.titleL),
      titleM: s(titleM, other.titleM),
      bodyL: s(bodyL, other.bodyL),
      bodyM: s(bodyM, other.bodyM),
      label: s(label, other.label),
      caption: s(caption, other.caption),
      button: s(button, other.button),
    );
  }
}
