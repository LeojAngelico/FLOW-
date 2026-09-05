import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import 'flow_frame_box.dart';

/// Which fill/depth/bevel token triple a [GamePanel] renders with.
enum GamePanelVariant {
  /// Everyday content block: `surfacePrimary` fill, no depth offset —
  /// sits flush with the canvas rather than reading as a pressable
  /// card. Pair its content with `color.textPrimary`/`textSecondary`.
  flat,

  /// The default onboarding form card: `panelDeep` fill, `frameDepth`
  /// offset and a `frameBevel` top highlight. `panelDeep` is
  /// deliberately dark in both themes, so pair its content with
  /// `color.panelDeepInk` (fixed white) for the primary value and
  /// `color.panelDeepAccent` (fixed light aqua) for secondary text —
  /// never `textPrimary`/`textSecondary`, which flip with the theme and
  /// can land near-invisible against this fill.
  deep,

  /// Celebratory content: `achievement` gold fill, same depth/bevel as
  /// [deep]. Pair its content with `color.onBrandFill`, the same
  /// theme-invariant navy `PrimaryButton`'s milestone fill already
  /// uses — `onPrimary` white fails WCAG 1.4.3 against this fill.
  milestone,
}

/// CMP-40. The onboarding card — a thin wrapper over [FlowFrameBox]
/// that fixes the fill/depth/bevel token triple per [GamePanelVariant]
/// so no screen picks those tokens ad hoc.
class GamePanel extends StatelessWidget {
  const GamePanel({
    required this.child,
    this.variant = GamePanelVariant.flat,
    this.padding = const EdgeInsets.all(FlowSpacing.md),
    super.key,
  });

  final Widget child;
  final GamePanelVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;

    final (Color fill, double depth) = switch (variant) {
      GamePanelVariant.flat => (colors.surfacePrimary, 0.0),
      GamePanelVariant.deep => (colors.panelDeep, 4.0),
      GamePanelVariant.milestone => (colors.achievement, 4.0),
    };

    return FlowFrameBox(
      fill: fill,
      frameInk: colors.frameInk,
      radius: FlowRadius.lg,
      depth: depth,
      depthColor: depth > 0 ? colors.frameDepth : null,
      bevelColor: depth > 0 ? colors.frameBevel : null,
      child: Padding(padding: padding, child: child),
    );
  }
}
