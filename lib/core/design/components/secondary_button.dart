import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

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

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.lg),
        alignment: Alignment.center,
        // Border lives in `foregroundDecoration`, not `decoration`: when a
        // bordered BoxDecoration is combined with an explicit `height` and a
        // child, Container adds the border width to the constrained size
        // (52dp becomes 56dp). foregroundDecoration paints on top without
        // affecting layout. See Task 15 (FlowFrameBox/PrimaryButton) for the
        // same gotcha.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FlowRadius.sm),
        ),
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
