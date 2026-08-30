import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

/// CMP-11. Range/step come from the caller (e.g. 25-250kg, step 0.5 for
/// the weight slider). The numeric field stays the accessible primary
/// control elsewhere on screen — this slider is an enhancement, exposed
/// to screen readers as "N kilograms" stepping by 1 whole unit.
class FlowSlider extends StatelessWidget {
  const FlowSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.rangeLabelBuilder,
    this.step = 0.5,
    this.unitLabel = 'kilograms',
    super.key,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String Function(double) rangeLabelBuilder;
  final double step;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final divisions = ((max - min) / step).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 12,
            activeTrackColor: colors.brandPrimary,
            inactiveTrackColor: colors.trackDark,
            thumbColor: colors.brandPrimary,
            overlayColor: colors.brandPrimary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Semantics(
            value: '${value.round()} $unitLabel',
            increasedValue: '${(value + 1).round()} $unitLabel',
            decreasedValue: '${(value - 1).round()} $unitLabel',
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              rangeLabelBuilder(min),
              style: typography.labelGame.copyWith(color: colors.textSecondary),
            ),
            Text(
              rangeLabelBuilder(max),
              style: typography.labelGame.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
