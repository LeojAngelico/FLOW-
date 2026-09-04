/// Corner-radius scale (06-design-system.md §4). `pill` is currently
/// unused by any real component — QuickAddChip uses a dedicated 10px
/// radius per the Figma verification, not a pill (see the foundation
/// design spec, Section 6).
class FlowRadius {
  FlowRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
  static const double quickAddChip = 10;

  /// The floating tab bar's corner radius (06-design-system.md §6, v3.5:
  /// "restyled as a floating pill ... 32dp radius"). Not on the general
  /// scale, same reasoning as [quickAddChip].
  static const double navBar = 32;
}
