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
}
