import 'package:flutter/material.dart';

/// Light-mode shadow elevation (06-design-system.md §5). Dark mode uses
/// surface-color steps instead of shadows (near-invisible on dark
/// backgrounds) — handled directly in FlowTheme's dark ColorScheme, not
/// here.
class FlowElevation {
  FlowElevation._();

  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x0F101820), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0A101820), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x14101820), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x1F101820), offset: Offset(0, 8), blurRadius: 24),
  ];
}
