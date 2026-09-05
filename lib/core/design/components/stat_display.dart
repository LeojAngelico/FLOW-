import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';
import 'flow_tappable.dart';
import 'game_panel.dart';

/// Whether a [StatDisplay] shows a bare value or adds a progress meter.
enum StatDisplayVariant {
  /// `type.pixelHero` value + `type.pixelUnit` unit only.
  valueAndUnit,

  /// [valueAndUnit] plus a horizontal meter bar — requires
  /// [StatDisplay.meterFraction].
  valueUnitAndMeter,
}

/// CMP-41. `ONB-04`'s weight hero: a `type.pixelHero` value and
/// `type.pixelUnit` unit inside a `GamePanelVariant.deep` [GamePanel].
/// The meter (when [variant] is [StatDisplayVariant.valueUnitAndMeter])
/// puts its bright fill on `color.trackDark`, **not** `trackSubtle` —
/// `trackSubtle` measured 1.83:1 against the bright fill on this panel
/// (`06 §2.5`), which is not enough contrast.
///
/// [onTap] makes the whole panel tappable — `ONB-04`'s hero is "tap to
/// type"; leave it `null` for a purely display-only reading.
class StatDisplay extends StatelessWidget {
  const StatDisplay({
    required this.value,
    required this.unit,
    this.variant = StatDisplayVariant.valueAndUnit,
    this.meterFraction,
    this.onTap,
    super.key,
  }) : assert(
         variant == StatDisplayVariant.valueAndUnit || meterFraction != null,
         'StatDisplayVariant.valueUnitAndMeter requires a meterFraction',
       );

  final String value;
  final String unit;
  final StatDisplayVariant variant;

  /// 0.0-1.0. Required when [variant] is
  /// [StatDisplayVariant.valueUnitAndMeter]; clamped before rendering.
  final double? meterFraction;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: typography.pixelHero.copyWith(color: colors.panelDeepInk),
            ),
            const SizedBox(width: FlowSpacing.sm),
            Text(
              unit,
              style: typography.pixelUnit.copyWith(
                color: colors.panelDeepAccent,
              ),
            ),
          ],
        ),
        if (variant == StatDisplayVariant.valueUnitAndMeter) ...[
          const SizedBox(height: FlowSpacing.md),
          _Meter(fraction: meterFraction!, colors: colors),
        ],
      ],
    );

    return GamePanel(
      variant: GamePanelVariant.deep,
      child: onTap == null
          ? content
          : FlowTappable(onTap: onTap, child: content),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.fraction, required this.colors});

  final double fraction;
  final FlowColors colors;

  @override
  Widget build(BuildContext context) {
    final clamped = fraction < 0.0 ? 0.0 : (fraction > 1.0 ? 1.0 : fraction);

    return ClipRRect(
      borderRadius: BorderRadius.circular(FlowRadius.sm),
      child: SizedBox(
        height: 12,
        child: Stack(
          children: [
            // The bright fill sits on trackDark, not trackSubtle — see
            // this file's class doc.
            ColoredBox(color: colors.trackDark),
            FractionallySizedBox(
              widthFactor: clamped,
              child: ColoredBox(color: colors.brandPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
