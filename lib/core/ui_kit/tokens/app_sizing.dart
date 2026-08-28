/// Sizing scale shared by every Core UI Kit component.
///
/// [minTouchTarget] follows platform accessibility guidance
/// (Material and Apple HIG both recommend ~48dp/44pt minimum).
class AppSizing {
  AppSizing._();

  static const double minTouchTarget = 48;

  static const double buttonHeight = 52;
  static const double buttonHeightCompact = 40;

  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;

  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 72;
}
