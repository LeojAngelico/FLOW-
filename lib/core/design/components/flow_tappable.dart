import 'package:flutter/material.dart';

/// Shared tap-handling + accessibility wrapper for every tappable
/// CMP-* component (final-review a11y follow-up: none of them exposed
/// `Semantics(button: true, ...)`, so a screen reader announced them
/// as plain, non-interactive content — a real accessibility gap, not
/// a cosmetic one).
///
/// [label] is only needed for a component with no visible text
/// descendant (e.g. an icon-only button) — [Semantics] otherwise folds
/// a component's own `Text` children into its accessible name
/// automatically. Do not pass [label] when a visible label `Text` is
/// also present: `Semantics.label` concatenates with a merged
/// descendant's own label rather than replacing it, so both together
/// announce the text twice (e.g. "Continue\nContinue").
class FlowTappable extends StatelessWidget {
  const FlowTappable({
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.label,
    this.selected,
    this.checked,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final String? label;
  final bool? selected;
  final bool? checked;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      checked: checked,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        onTapDown: enabled ? onTapDown : null,
        onTapUp: enabled ? onTapUp : null,
        onTapCancel: enabled ? onTapCancel : null,
        child: child,
      ),
    );
  }
}
