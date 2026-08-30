import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-03. Text-only tappable link, 48dp tall regardless of label
/// length — a real hit target, not just the text glyph bounds (needed
/// explicitly for the ONB-08 Skip control). Label color is always
/// brandPrimaryTextSafe, never raw brandPrimary (2.32:1 contrast
/// failure). The [showIcon] = false case is the Skip/"NoIcon" variant.
class FlowTextButton extends StatelessWidget {
  const FlowTextButton({
    required this.label,
    required this.onPressed,
    this.showIcon = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isDisabled = onPressed == null;
    final labelColor = isDisabled
        ? colors.textSecondary
        : colors.brandPrimaryTextSafe;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.smMd),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              SvgPicture.asset(
                'assets/icons/onboarding/icon-info.svg',
                width: 20,
                height: 26,
              ),
              const SizedBox(width: FlowSpacing.sm),
            ],
            Flexible(
              child: Text(
                label,
                style: typography.bodyM.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
