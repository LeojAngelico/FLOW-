import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';
import 'flow_tappable.dart';

/// CMP-15. 40dp circle, single-letter day label. On = brand.primary
/// fill + 2dp frame.ink border + onBrandFill navy label (fixed in both
/// themes — textPrimary would flip to near-white in dark mode against
/// this theme-invariant fill and fail WCAG 1.4.3, as PrimaryButton's
/// doc comment explains).
class DayToggle extends StatelessWidget {
  const DayToggle({
    required this.dayLetter,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String dayLetter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return FlowTappable(
      onTap: onTap,
      selected: selected,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.brandPrimary : colors.surfacePrimary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.frameInk, width: 2),
        ),
        child: Text(
          dayLetter.toUpperCase(),
          style: typography.labelGame.copyWith(
            color: selected ? colors.onBrandFill : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
