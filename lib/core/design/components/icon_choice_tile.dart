import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-07. 2x2 grid tile (ONB-06), built at 104dp (Figma's own note:
/// "min 96dp tall per 05 ONB-06; built at 104dp"). Selected = tinted
/// fill + 3dp frame + check badge, same three-cue pattern as CMP-06.
class IconChoiceTile extends StatelessWidget {
  const IconChoiceTile({
    required this.label,
    required this.level,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.symmetric(vertical: FlowSpacing.md),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceTinted : colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: selected ? 3 : 2),
          borderRadius: BorderRadius.circular(FlowRadius.md),
        ),
        // Stack, not a taller Column: the given brief stacked the
        // selection badge *below* the label inside this fixed 104dp
        // tile, which overflowed by 24px once the badge's own height
        // was added to the thermometer + label. Overlaying the badge in
        // the corner keeps the same three-cue selection pattern (tinted
        // fill + thicker frame + badge) without growing past 104dp.
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ThermometerIndicator(level: level, colors: colors),
                const SizedBox(height: FlowSpacing.sm),
                Text(
                  label,
                  style: typography.titleM.copyWith(color: colors.textPrimary),
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.frameInk, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for the missing thermometer asset — see this task's
/// "Missing-asset note." Fill height and color both move with [level]
/// so temperature reads through two channels, not one.
class _ThermometerIndicator extends StatelessWidget {
  const _ThermometerIndicator({required this.level, required this.colors});

  final int level;
  final FlowColors colors;

  @override
  Widget build(BuildContext context) {
    final levelColors = [
      colors.panelDeepAccent, // 1: temperate — aqua
      colors.achievement, // 2: warm — gold
      // 3: hot — orange. No matching FlowColors token exists for this
      // shade; kept as a literal.
      const Color(0xFFFF9142),
      colors.reward, // 4: very hot — coral
    ];
    final color = levelColors[(level - 1).clamp(0, 3)];
    final fillFraction = level / 4;

    return SizedBox(
      width: 20,
      height: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillFraction,
                child: Container(width: 8, color: color),
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
