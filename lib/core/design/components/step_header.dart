import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';
import 'flow_frame_box.dart';
import 'flow_tappable.dart';
import 'pixel_icon.dart';
import 'step_track.dart';

/// CMP-09. The header shared by ONB-03 to ONB-07: a 48dp back chevron,
/// the caller-supplied "Step N of 5" string ([stepLabel], `CPY-030` —
/// this component reads no l10n for it, matching hydration Decisions
/// #23's "components never read Riverpod" extended to copy), and the
/// existing [StepTrack] (CMP-44).
///
/// The chevron button is built here from [FlowFrameBox] + [PixelIcon]
/// directly rather than composing the existing `FlowBackButton` — this
/// plan's Core file list calls out `PixelIcon` by name for this
/// element, and `FlowBackButton` predates `PixelIcon`. The two now
/// render the same 48dp/depth-3 recipe; a future pass could fold
/// `FlowBackButton` to wrap this same chevron, but that refactor is out
/// of scope for this dispatch.
///
/// [onBack] null disables the chevron and its semantics — `ONB-03`, the
/// first step, has nowhere onboarding-internal to go back to.
class StepHeader extends StatelessWidget {
  const StepHeader({
    required this.stepLabel,
    required this.currentStep,
    this.totalSteps = 5,
    this.onBack,
    super.key,
  });

  final String stepLabel;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  static const _backChevronAsset =
      'assets/icons/onboarding/icon-chevron-left.svg';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            FlowTappable(
              onTap: onBack,
              enabled: onBack != null,
              label: loc.back,
              child: FlowFrameBox(
                fill: colors.surfacePrimary,
                frameInk: colors.frameInk,
                depth: 3,
                depthColor: colors.frameDepth,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: PixelIcon(
                      asset: _backChevronAsset,
                      size: PixelIconSize.sm,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: FlowSpacing.md),
            Expanded(
              child: Text(
                stepLabel,
                style: typography.labelGame.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FlowSpacing.sm),
        StepTrack(currentStep: currentStep, totalSteps: totalSteps),
      ],
    );
  }
}
