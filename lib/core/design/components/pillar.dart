import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-08. Welcome-screen (ONB-02) value-prop row. Static — no
/// selection state. 28dp leading icon. Icon-to-content mapping used by
/// the welcome screen (Task 32): Hydrate -> icon-droplet, Progress ->
/// icon-chart, Learn -> icon-book.
class Pillar extends StatelessWidget {
  const Pillar({
    required this.iconAsset,
    required this.title,
    required this.description,
    super.key,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(
        horizontal: FlowSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.frameInk, width: 2),
        borderRadius: BorderRadius.circular(FlowRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: SvgPicture.asset(iconAsset)),
          const SizedBox(width: FlowSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: typography.titleM.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: typography.bodyM.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
