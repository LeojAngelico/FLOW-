import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_motion.dart';

/// The 240dp hero size (the dashboard) vs. the 160dp compact size (a
/// summary card).
enum HydrationGlassSize { hero, compact }

/// CMP-47, the product's signature element. Supersedes `CMP-17
/// HydrationRing`, retired by `06-design-system.md` v3.2 — see
/// `docs/workplans/2026-09-04-hydration-logging.md` Decisions #4. Do
/// not resurrect the ring.
///
/// [currentMl] / [targetMl] are raw values, not a pre-capped fraction —
/// this widget clamps `current / target` to `1.0` itself for the
/// *graphic* (`FR-033`: the fill must never overflow past a full glass
/// even once the total passes the target; the textual readout showing
/// the true, uncapped total lives in `hydration_summary.dart`, not
/// here).
///
/// The fill retargets with an implicit animation
/// ([FlowMotion.slow]/[FlowMotion.slowCurve]) — `TweenAnimationBuilder`
/// smoothly re-interpolates from whatever the fill is currently showing
/// when [currentMl] changes mid-animation, so rapid successive logs
/// retarget rather than restarting or jumping backwards. [reduceMotion]
/// collapses that to an instant jump.
///
/// This component reads no Riverpod state itself — no other `CMP-*`
/// component does, per the existing 18 in this directory — so the
/// caller passes `ref.watch(reduceMotionProvider)` through as a plain
/// bool. It also excludes itself from the semantics tree: the
/// containing composite (`hydration_summary.dart`) is responsible for
/// exposing today's progress as a single accessible node, per the
/// workplan's APP-01 a11y requirement.
///
/// **Asset note** (Decisions #4): built from
/// `assets/icons/onboarding/sprite-glass-shell.svg`,
/// `sprite-glass-outline.svg` and `sprite-water-fill.svg`, drawn
/// originally for onboarding. If they do not hold up at 240dp, that is
/// a design task to raise, not a reason to fall back to a ring.
class HydrationGlass extends StatelessWidget {
  const HydrationGlass({
    required this.currentMl,
    required this.targetMl,
    this.size = HydrationGlassSize.hero,
    this.goalCompleted = false,
    this.reduceMotion = false,
    super.key,
  });

  /// Today's total. May exceed [targetMl] once the goal is passed.
  final int currentMl;

  /// The effective daily target (the schema's own `CHECK` constraint
  /// keeps a real value between 500 and 4,000). A non-positive value
  /// renders an empty glass rather than dividing by zero.
  final int targetMl;

  final HydrationGlassSize size;

  /// Drives the success tint over the fill once the goal is met.
  final bool goalCompleted;

  /// True under `MediaQuery.disableAnimations` — see the class doc.
  final bool reduceMotion;

  static const double _heroSize = 240;
  static const double _compactSize = 160;

  static const _shellAsset = 'assets/icons/onboarding/sprite-glass-shell.svg';
  static const _outlineAsset =
      'assets/icons/onboarding/sprite-glass-outline.svg';
  static const _waterFillAsset =
      'assets/icons/onboarding/sprite-water-fill.svg';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final dimension = size == HydrationGlassSize.hero
        ? _heroSize
        : _compactSize;
    final rawFraction = targetMl > 0 ? currentMl / targetMl : 0.0;
    // `num.clamp` returns `num`, not `double` — branch explicitly
    // instead, matching `TodayHydration.displayFraction`'s own style.
    final fraction = rawFraction < 0.0
        ? 0.0
        : (rawFraction > 1.0 ? 1.0 : rawFraction);

    return ExcludeSemantics(
      child: SizedBox(
        key: const ValueKey('hydration-glass'),
        width: dimension,
        height: dimension,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(_shellAsset, fit: BoxFit.contain),
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: fraction),
                  duration: reduceMotion ? FlowMotion.instant : FlowMotion.slow,
                  curve: FlowMotion.slowCurve,
                  builder: (context, value, child) {
                    final clamped = value < 0.0
                        ? 0.0
                        : (value > 1.0 ? 1.0 : value);
                    return FractionallySizedBox(
                      heightFactor: clamped,
                      widthFactor: 1,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SvgPicture.asset(_waterFillAsset, fit: BoxFit.fill),
                      AnimatedOpacity(
                        duration: reduceMotion
                            ? FlowMotion.instant
                            : FlowMotion.base,
                        opacity: goalCompleted ? 1 : 0,
                        child: ColoredBox(
                          color: colors.success.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SvgPicture.asset(_outlineAsset, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
