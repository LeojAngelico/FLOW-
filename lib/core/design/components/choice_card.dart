import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-06. Activity-level row (ONB-05). Min height 76dp. The leading
/// pixel bar-meter (1-5 bars filled) ties the choice to "player stat"
/// language rather than a generic icon. Selected = tinted fill + 3dp
/// frame (thicker, not just recolored) + trailing check-badge — never
/// color alone.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.title,
    required this.description,
    required this.barsFilled,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final int barsFilled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(
          horizontal: FlowSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceTinted : colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: selected ? 3 : 2),
          borderRadius: BorderRadius.circular(FlowRadius.md),
        ),
        child: Row(
          children: [
            _BarMeter(filled: barsFilled, colors: colors),
            const SizedBox(width: FlowSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: typography.titleM.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: typography.bodyM.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: FlowSpacing.md),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.brandPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.frameInk, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  'assets/icons/onboarding/icon-check.svg',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarMeter extends StatelessWidget {
  const _BarMeter({required this.filled, required this.colors});

  final int filled;
  final FlowColors colors;

  @override
  Widget build(BuildContext context) {
    const heights = [8.0, 12.0, 16.0, 20.0, 24.0];

    return SizedBox(
      width: 32,
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 5; i++)
            // The shared ValueKey lives on this inner SizedBox rather than
            // directly on the Row's child: Flutter asserts that direct
            // siblings under the same multi-child element (Row.children)
            // have unique keys, and all 5 bars intentionally share one key
            // value so the test can find all of them via find.byKey.
            // Nesting one level down keeps them from being siblings of
            // each other while the shared key is still discoverable.
            SizedBox(
              width: 4,
              height: heights[i],
              child: Container(
                key: const ValueKey('choice-card-bar'),
                decoration: BoxDecoration(
                  color: i < filled ? colors.brandPrimary : colors.trackSubtle,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
