import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/design/tokens/flow_colors.dart';
import '../core/design/tokens/flow_elevation.dart';
import '../core/design/tokens/flow_radius.dart';
import '../core/design/tokens/flow_spacing.dart';
import '../core/design/tokens/flow_typography.dart';

/// One tab in [FlowBottomNav]: the bundled pixel-icon asset path and
/// its label.
class FlowNavDestination {
  const FlowNavDestination({required this.iconAsset, required this.label});

  final String iconAsset;
  final String label;
}

/// The floating pixel-icon tab bar (06-design-system.md §6, v3.5:
/// "BottomNavigation restyled as a floating pill" — elevation.2-class
/// shadow, 32dp radius, 328dp inset width on the 360dp reference
/// viewport, i.e. 16dp/FlowSpacing.md margin per side).
///
/// Pinned to the light-theme game-surface palette in BOTH app themes,
/// deliberately: the bundled tab icons are pixel art with colors baked
/// into the SVG (ink navy + white), not theme-aware, like every other
/// CMP-* icon in this library (none apply a ColorFilter). A panel that
/// darkened independently of them would reproduce the near-invisible
/// icon failure just fixed in PrimaryButton/DayToggle — see FlowColors'
/// class doc comment on `onBrandFill`/`frameInk`.
class FlowBottomNav extends StatelessWidget {
  const FlowBottomNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FlowNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FlowSpacing.md,
          FlowSpacing.xs,
          FlowSpacing.md,
          FlowSpacing.xs,
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: FlowColors.light.canvasGame,
            borderRadius: BorderRadius.circular(FlowRadius.navBar),
            border: Border.all(color: FlowColors.light.frameInk, width: 2),
            boxShadow: FlowElevation.level2,
          ),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _FlowNavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onDestinationSelected(i),
                    typography: typography,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowNavItem extends StatelessWidget {
  const _FlowNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.typography,
  });

  final FlowNavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final FlowTypography typography;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: selected ? 1 : 0.55,
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: FlowSpacing.xs,
              horizontal: FlowSpacing.xs2,
            ),
            decoration: selected
                ? BoxDecoration(
                    color: FlowColors.light.surfaceTinted,
                    borderRadius: BorderRadius.circular(FlowRadius.md),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(destination.iconAsset),
                ),
                const SizedBox(height: FlowSpacing.xs2),
                Text(
                  destination.label,
                  style: typography.labelGame.copyWith(
                    color: FlowColors.light.frameInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
