import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_typography.dart';
import 'flow_tappable.dart';

/// CMP-04. 56dp tall, a dedicated 10px radius — NOT radius.pill. The
/// written design-system doc reserved radius.pill for this component,
/// but the actual built chip in Figma uses 10px (see the foundation
/// design spec, Section 6); radius.pill is unused by the current design.
class QuickAddChip extends StatelessWidget {
  const QuickAddChip({
    required this.amountMl,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final int amountMl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    final fill = selected ? colors.brandPrimary : colors.surfacePrimary;
    final labelColor = colors.textPrimary;
    final borderWidth = selected ? 3.0 : 2.0;

    return FlowTappable(
      onTap: onTap,
      selected: selected,
      child: Container(
        key: const ValueKey('quick-add-chip'),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: colors.frameInk, width: borderWidth),
          borderRadius: BorderRadius.circular(FlowRadius.quickAddChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 11,
              height: 14,
              child: SvgPicture.asset(
                'assets/icons/onboarding/icon-droplet.svg',
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$amountMl ML',
              style: typography.labelGame.copyWith(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
