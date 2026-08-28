import 'package:flutter/material.dart';

/// A selectable filter/choice chip, themed to match the rest of
/// the kit. Thin wrapper over [FilterChip] — Material 3 already
/// themes chips reasonably via [ColorScheme], so this mainly
/// standardizes the call site rather than restyling anything.
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 18) : null,
    );
  }
}
