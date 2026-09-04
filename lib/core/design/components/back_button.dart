import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../tokens/flow_colors.dart';
import 'flow_frame_box.dart';
import 'flow_tappable.dart';

/// CMP-42. 48x48dp touch target, framed to match the button system but
/// with a shallower 3dp depth than CMP-01's 4dp, so it reads as
/// secondary. Onboarding uses no Material Symbols — this is the bundled
/// pixel chevron-left asset, reused (rotated) by CMP-14 SettingRow.
///
/// Icon-only, no visible text, so [FlowTappable] needs an explicit
/// `label` (final-review a11y follow-up) — without one, a screen reader
/// announced this control with no accessible name at all.
class FlowBackButton extends StatelessWidget {
  const FlowBackButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final loc = AppLocalizations.of(context)!;

    return FlowTappable(
      onTap: onPressed,
      enabled: onPressed != null,
      label: loc.back,
      child: FlowFrameBox(
        fill: colors.surfacePrimary,
        frameInk: colors.frameInk,
        depth: 3,
        depthColor: colors.frameDepth,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 22,
              child: SvgPicture.asset(
                'assets/icons/onboarding/icon-chevron-left.svg',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
