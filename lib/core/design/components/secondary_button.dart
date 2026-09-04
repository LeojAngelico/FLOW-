import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';
import 'flow_tappable.dart';

/// CMP-02. Outline only, no fill, no depth — deliberately 4dp shorter
/// than CMP-01's 60dp footprint so it visibly sits lower in the
/// hierarchy without needing a lighter color.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isDisabled = widget.onPressed == null;

    final Color borderColor;
    final Color labelColor;
    if (isDisabled) {
      borderColor = colors.surfacePrimary;
      labelColor = colors.textSecondary;
    } else if (_pressed) {
      borderColor = colors.brandPrimary;
      labelColor = colors.textPrimary;
    } else {
      borderColor = colors.frameInk;
      labelColor = colors.textPrimary;
    }

    return FlowTappable(
      enabled: !isDisabled,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.lg),
        alignment: Alignment.center,
        // Border lives in `foregroundDecoration`, not `decoration`. This
        // Container has an explicit `height: 52`, so the outer rendered
        // height is 52dp either way — a tight height always wins over
        // border-induced padding (unlike FlowFrameBox in Task 15, which
        // shrink-wraps with no explicit height/constraints, where border
        // placement does change the final size). The reason to use
        // foregroundDecoration here is narrower: a border inside
        // `decoration` becomes `BoxDecoration.padding` around the child,
        // squeezing the label's available height by the border width
        // (~48dp instead of 52dp). Painting the border in
        // `foregroundDecoration` instead leaves the child the full 52dp.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(FlowRadius.sm),
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: typography.buttonGame.copyWith(color: labelColor),
        ),
      ),
    );
  }
}
