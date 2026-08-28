import 'package:flutter/material.dart';

/// Every color token from 06-design-system.md §2, verified against the
/// Figma file's bound variables (see the foundation design spec, Section
/// 6). `panelDeep`, `trackDark`, and `canvasGame` are genuinely
/// theme-dependent — a correction found during that verification, not
/// present in the original written doc.
class FlowColors extends ThemeExtension<FlowColors> {
  const FlowColors({
    required this.brandPrimary,
    required this.brandPrimaryTextSafe,
    required this.brandPrimaryPressed,
    required this.brandPrimaryActive,
    required this.brandSecondary,
    required this.xp,
    required this.achievement,
    required this.reward,
    required this.streak,
    required this.backgroundPrimary,
    required this.surfacePrimary,
    required this.surfaceTinted,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.onPrimary,
    required this.trackSubtle,
    required this.success,
    required this.successSurface,
    required this.error,
    required this.errorSurface,
    required this.warning,
    required this.warningSurface,
    required this.info,
    required this.infoSurface,
    required this.streakSurface,
    required this.scrim,
    required this.canvasGame,
    required this.panelDeep,
    required this.panelDeepInk,
    required this.panelDeepAccent,
    required this.frameInk,
    required this.frameDepth,
    required this.frameBevel,
    required this.particle,
    required this.trackDark,
  });

  final Color brandPrimary;
  final Color brandPrimaryTextSafe;
  final Color brandPrimaryPressed;
  final Color brandPrimaryActive;
  final Color brandSecondary;
  final Color xp;
  final Color achievement;
  final Color reward;
  final Color streak;

  final Color backgroundPrimary;
  final Color surfacePrimary;
  final Color surfaceTinted;
  final Color surfaceAlt;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color onPrimary;
  final Color trackSubtle;
  final Color success;
  final Color successSurface;
  final Color error;
  final Color errorSurface;
  final Color warning;
  final Color warningSurface;
  final Color info;
  final Color infoSurface;
  final Color streakSurface;
  final Color scrim;

  final Color canvasGame;
  final Color panelDeep;
  final Color panelDeepInk;
  final Color panelDeepAccent;
  final Color frameInk;
  final Color frameDepth;
  final Color frameBevel;
  final Color particle;
  final Color trackDark;

  static const FlowColors light = FlowColors(
    brandPrimary: Color(0xFF2FB6F0),
    brandPrimaryTextSafe: Color(0xFF0A6E9E),
    brandPrimaryPressed: Color(0xFF085A82),
    brandPrimaryActive: Color(0xFF1C9AD1),
    brandSecondary: Color(0xFF8B6BF2),
    xp: Color(0xFF8BD450),
    achievement: Color(0xFFFFC542),
    reward: Color(0xFFFF7A59),
    streak: Color(0xFFB45309),
    backgroundPrimary: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFF7FAFD),
    surfaceTinted: Color(0xFFE4F5FD),
    surfaceAlt: Color(0xFFEEF2F6),
    border: Color(0xFFD7DEE6),
    borderStrong: Color(0xFFAEBBC8),
    textPrimary: Color(0xFF101A2E),
    textSecondary: Color(0xFF4A5763),
    textDisabled: Color(0xFF6B7885),
    onPrimary: Color(0xFFFFFFFF),
    trackSubtle: Color(0xFFDCE6EF),
    success: Color(0xFF147A52),
    successSurface: Color(0xFFE4F5EE),
    error: Color(0xFFC22A2E),
    errorSurface: Color(0xFFFCEBEA),
    warning: Color(0xFFA85A08),
    warningSurface: Color(0xFFFDF8EC),
    info: Color(0xFF0A6E9E),
    infoSurface: Color(0xFFE6F2FB),
    streakSurface: Color(0xFFFDF1E3),
    scrim: Color(0x99101A2E),
    canvasGame: Color(0xFFE4F5FD),
    panelDeep: Color(0xFF085A82),
    panelDeepInk: Color(0xFFFFFFFF),
    panelDeepAccent: Color(0xFF7FDBFA),
    frameInk: Color(0xFF0B1E36),
    frameDepth: Color(0xFF0A3E5C),
    frameBevel: Color(0x595FCBF5),
    particle: Color(0x4D7FDBFA),
    trackDark: Color(0xFF143A52),
  );

  static const FlowColors dark = FlowColors(
    brandPrimary: Color(0xFF2FB6F0),
    brandPrimaryTextSafe: Color(0xFF2FB6F0),
    brandPrimaryPressed: Color(0xFF085A82),
    brandPrimaryActive: Color(0xFF1C9AD1),
    brandSecondary: Color(0xFFA488FF),
    xp: Color(0xFF8BD450),
    achievement: Color(0xFFFFC542),
    reward: Color(0xFFFF7A59),
    streak: Color(0xFFF5A15C),
    backgroundPrimary: Color(0xFF101A33),
    surfacePrimary: Color(0xFF182347),
    surfaceTinted: Color(0xFF1C2B57),
    surfaceAlt: Color(0xFF202F5E),
    border: Color(0xFF2A3A66),
    borderStrong: Color(0xFF3D4F8A),
    textPrimary: Color(0xFFEAF2FF),
    textSecondary: Color(0xFFA9B8D6),
    textDisabled: Color(0xFF8593A1),
    onPrimary: Color(0xFF08243A),
    trackSubtle: Color(0xFF22315C),
    success: Color(0xFF2FBE79),
    successSurface: Color(0xFF182347),
    error: Color(0xFFFF6B6B),
    errorSurface: Color(0xFF182347),
    warning: Color(0xFFFFA940),
    warningSurface: Color(0xFF182347),
    info: Color(0xFF2FB6F0),
    infoSurface: Color(0xFF182347),
    streakSurface: Color(0xFF182347),
    scrim: Color(0xB3000000),
    canvasGame: Color(0xFF101A33),
    panelDeep: Color(0xFF06405E),
    panelDeepInk: Color(0xFFFFFFFF),
    panelDeepAccent: Color(0xFF7FDBFA),
    frameInk: Color(0xFF0B1E36),
    frameDepth: Color(0xFF0A3E5C),
    frameBevel: Color(0x595FCBF5),
    particle: Color(0x4D7FDBFA),
    trackDark: Color(0xFF0C2436),
  );

  @override
  FlowColors copyWith({
    Color? brandPrimary,
    Color? brandPrimaryTextSafe,
    Color? brandPrimaryPressed,
    Color? brandPrimaryActive,
    Color? brandSecondary,
    Color? xp,
    Color? achievement,
    Color? reward,
    Color? streak,
    Color? backgroundPrimary,
    Color? surfacePrimary,
    Color? surfaceTinted,
    Color? surfaceAlt,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? onPrimary,
    Color? trackSubtle,
    Color? success,
    Color? successSurface,
    Color? error,
    Color? errorSurface,
    Color? warning,
    Color? warningSurface,
    Color? info,
    Color? infoSurface,
    Color? streakSurface,
    Color? scrim,
    Color? canvasGame,
    Color? panelDeep,
    Color? panelDeepInk,
    Color? panelDeepAccent,
    Color? frameInk,
    Color? frameDepth,
    Color? frameBevel,
    Color? particle,
    Color? trackDark,
  }) {
    return FlowColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryTextSafe: brandPrimaryTextSafe ?? this.brandPrimaryTextSafe,
      brandPrimaryPressed: brandPrimaryPressed ?? this.brandPrimaryPressed,
      brandPrimaryActive: brandPrimaryActive ?? this.brandPrimaryActive,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      xp: xp ?? this.xp,
      achievement: achievement ?? this.achievement,
      reward: reward ?? this.reward,
      streak: streak ?? this.streak,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceTinted: surfaceTinted ?? this.surfaceTinted,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      onPrimary: onPrimary ?? this.onPrimary,
      trackSubtle: trackSubtle ?? this.trackSubtle,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      error: error ?? this.error,
      errorSurface: errorSurface ?? this.errorSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      info: info ?? this.info,
      infoSurface: infoSurface ?? this.infoSurface,
      streakSurface: streakSurface ?? this.streakSurface,
      scrim: scrim ?? this.scrim,
      canvasGame: canvasGame ?? this.canvasGame,
      panelDeep: panelDeep ?? this.panelDeep,
      panelDeepInk: panelDeepInk ?? this.panelDeepInk,
      panelDeepAccent: panelDeepAccent ?? this.panelDeepAccent,
      frameInk: frameInk ?? this.frameInk,
      frameDepth: frameDepth ?? this.frameDepth,
      frameBevel: frameBevel ?? this.frameBevel,
      particle: particle ?? this.particle,
      trackDark: trackDark ?? this.trackDark,
    );
  }

  @override
  FlowColors lerp(ThemeExtension<FlowColors>? other, double t) {
    if (other is! FlowColors) {
      return this;
    }

    Color c(Color a, Color b) => Color.lerp(a, b, t)!;

    return FlowColors(
      brandPrimary: c(brandPrimary, other.brandPrimary),
      brandPrimaryTextSafe: c(brandPrimaryTextSafe, other.brandPrimaryTextSafe),
      brandPrimaryPressed: c(brandPrimaryPressed, other.brandPrimaryPressed),
      brandPrimaryActive: c(brandPrimaryActive, other.brandPrimaryActive),
      brandSecondary: c(brandSecondary, other.brandSecondary),
      xp: c(xp, other.xp),
      achievement: c(achievement, other.achievement),
      reward: c(reward, other.reward),
      streak: c(streak, other.streak),
      backgroundPrimary: c(backgroundPrimary, other.backgroundPrimary),
      surfacePrimary: c(surfacePrimary, other.surfacePrimary),
      surfaceTinted: c(surfaceTinted, other.surfaceTinted),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textDisabled: c(textDisabled, other.textDisabled),
      onPrimary: c(onPrimary, other.onPrimary),
      trackSubtle: c(trackSubtle, other.trackSubtle),
      success: c(success, other.success),
      successSurface: c(successSurface, other.successSurface),
      error: c(error, other.error),
      errorSurface: c(errorSurface, other.errorSurface),
      warning: c(warning, other.warning),
      warningSurface: c(warningSurface, other.warningSurface),
      info: c(info, other.info),
      infoSurface: c(infoSurface, other.infoSurface),
      streakSurface: c(streakSurface, other.streakSurface),
      scrim: c(scrim, other.scrim),
      canvasGame: c(canvasGame, other.canvasGame),
      panelDeep: c(panelDeep, other.panelDeep),
      panelDeepInk: c(panelDeepInk, other.panelDeepInk),
      panelDeepAccent: c(panelDeepAccent, other.panelDeepAccent),
      frameInk: c(frameInk, other.frameInk),
      frameDepth: c(frameDepth, other.frameDepth),
      frameBevel: c(frameBevel, other.frameBevel),
      particle: c(particle, other.particle),
      trackDark: c(trackDark, other.trackDark),
    );
  }
}
