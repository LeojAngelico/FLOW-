import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';
import 'flow_frame_box.dart';

/// CMP-01. Primary CTA. 56dp tall + 4dp solid frame/depth offset (60dp
/// total layout height). Label is text/primary navy on brand/primary —
/// never onPrimary white, which fails WCAG 1.4.3 at 2.32:1. Pressed
/// collapses the depth offset; that collapse IS the tap affordance.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.isMilestone = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final bool isMilestone;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    final Color fill;
    final Color labelColor;
    final Color frameColor;

    if (_isDisabled) {
      fill = colors.border;
      labelColor = colors.textDisabled;
      frameColor = colors.borderStrong;
    } else {
      fill = _pressed
          ? colors.brandPrimaryActive
          : widget.isMilestone
          ? colors.achievement
          : colors.brandPrimary;
      labelColor = colors.textPrimary;
      frameColor = colors.frameInk;
    }

    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: _isDisabled ? null : () => setState(() => _pressed = false),
      onTapUp: _isDisabled ? null : (_) => setState(() => _pressed = false),
      onTap: _isDisabled ? null : widget.onPressed,
      child: FlowFrameBox(
        fill: fill,
        frameInk: frameColor,
        radius: FlowRadius.sm,
        depth: _isDisabled || _pressed ? 0 : 4,
        depthColor: colors.frameDepth,
        bevelColor: _isDisabled ? null : colors.frameBevel,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: labelColor,
                    ),
                  )
                else ...[
                  Text(
                    widget.label.toUpperCase(),
                    style: typography.buttonGame.copyWith(color: labelColor),
                  ),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: FlowSpacing.sm),
                    Icon(widget.trailingIcon, size: 22, color: labelColor),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
