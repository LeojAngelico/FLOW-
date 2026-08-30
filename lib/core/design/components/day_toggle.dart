import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

/// CMP-15. 40dp circle, single-letter day label. On = brand.primary
/// fill + 2dp frame.ink border + navy label.
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

    return GestureDetector(
      onTap: onTap,
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
            color: selected ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
