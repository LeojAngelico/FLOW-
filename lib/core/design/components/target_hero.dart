import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';
import 'flow_slider.dart';
import 'game_panel.dart';
import 'stepper_button.dart';

/// Whether a [TargetHero] shows the read-only suggestion or the
/// in-place ±50ml/slider editor. Deliberately not named `TargetMode` —
/// that name belongs to `target_state.dart`'s three-state
/// `suggested`/`editing`/`edited` notifier state; this is the simpler
/// two-state view concern of "does this hero show controls."
enum TargetHeroMode { viewing, editing }

/// CMP-54. `ONB-07`'s accept/adjust hero — an eyebrow label, ±
/// [StepperButton]s (CMP-23), the pixel value, a [FlowSlider] (CMP-11)
/// and range labels, inside a `GamePanelVariant.deep` [GamePanel].
/// `APP-08` (`FR-101`) reuses this unchanged.
///
/// [mode] controls which controls render: [TargetHeroMode.viewing]
/// shows only the eyebrow and the value; [TargetHeroMode.editing] adds
/// the stepper buttons, the slider and the range labels around it.
class TargetHero extends StatelessWidget {
  const TargetHero({
    required this.eyebrow,
    required this.valueMl,
    required this.rangeLabelBuilder,
    this.mode = TargetHeroMode.viewing,
    this.onDecrement,
    this.onIncrement,
    this.onSliderChanged,
    this.minMl = 500,
    this.maxMl = 4000,
    super.key,
  });

  final String eyebrow;
  final int valueMl;

  /// Formats a raw ml value for the slider's min/max range labels
  /// (e.g. `'500'`/`'4,000'`) — the caller owns unit formatting.
  final String Function(double) rangeLabelBuilder;

  final TargetHeroMode mode;

  /// Ignored in [TargetHeroMode.viewing]. `null` in
  /// [TargetHeroMode.editing] disables that stepper button (e.g. at a
  /// bound).
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final ValueChanged<double>? onSliderChanged;

  final int minMl;
  final int maxMl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isEditing = mode == TargetHeroMode.editing;

    return GamePanel(
      variant: GamePanelVariant.deep,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: typography.labelGame.copyWith(color: colors.panelDeepAccent),
          ),
          const SizedBox(height: FlowSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isEditing) ...[
                StepperButton(
                  direction: StepDirection.decrement,
                  onStep: onDecrement ?? _noop,
                  enabled: onDecrement != null,
                ),
                const SizedBox(width: FlowSpacing.md),
              ],
              Text(
                '$valueMl',
                style: typography.pixelHero.copyWith(
                  color: colors.panelDeepInk,
                ),
              ),
              if (isEditing) ...[
                const SizedBox(width: FlowSpacing.md),
                StepperButton(
                  direction: StepDirection.increment,
                  onStep: onIncrement ?? _noop,
                  enabled: onIncrement != null,
                ),
              ],
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: FlowSpacing.md),
            FlowSlider(
              value: valueMl.toDouble(),
              min: minMl.toDouble(),
              max: maxMl.toDouble(),
              step: 50,
              unitLabel: 'milliliters',
              onChanged: onSliderChanged ?? (_) {},
              rangeLabelBuilder: rangeLabelBuilder,
            ),
          ],
        ],
      ),
    );
  }
}

void _noop() {}
