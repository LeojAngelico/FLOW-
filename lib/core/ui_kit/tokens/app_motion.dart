/// Animation timing shared by every Core UI Kit component.
///
/// Kept deliberately restrained — the kit favors subtle, quick
/// transitions over decorative motion.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}
