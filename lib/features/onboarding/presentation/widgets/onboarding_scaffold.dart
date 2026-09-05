import 'package:flutter/material.dart';

import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';

/// The single scaffold every onboarding screen composes through — `13
/// §14.1`: *"one scaffold across all eight screens."* The single
/// highest-leverage file in this pass: a screen that reaches for its
/// own `Scaffold` instead breaks the game-forward system for the whole
/// flow (Decisions #13).
///
/// Owns: the `color.canvas.game` ground (never white), a pixel
/// environment band with scattered `color.particle` bubbles behind
/// [header] (`13 §13`: atmosphere, never behind body text — the band
/// sits only above the scrolling [body], never overlapping it), the
/// 16dp gutter, the 480dp max content width, and keyboard avoidance
/// with 16dp clearance above the keyboard.
///
/// [header] is typically a `StepHeader` (`ONB-03`–`ONB-07`); `ONB-02`
/// and `ONB-08` render their own top row instead and pass `null`.
/// [cta] is typically a `CtaSection`.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.body,
    this.header,
    this.cta,
    super.key,
  });

  final Widget? header;
  final Widget body;
  final Widget? cta;

  static const double _maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: colors.canvasGame,
      body: Stack(
        children: [
          if (header != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: ExcludeSemantics(child: _GameBand(colors: colors)),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      FlowSpacing.md,
                      FlowSpacing.md,
                      FlowSpacing.md,
                      FlowSpacing.sm,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxContentWidth,
                        ),
                        child: header,
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          FlowSpacing.md,
                          header == null ? FlowSpacing.md : 0,
                          FlowSpacing.md,
                          bottomInset + FlowSpacing.md,
                        ),
                        child: body,
                      ),
                    ),
                  ),
                ),
                if (cta != null)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: cta,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The decorative pixel-environment band behind
/// [OnboardingScaffold.header] (`13 §14.1`). Purely atmospheric — the
/// caller excludes it from semantics and hit-testing.
class _GameBand extends StatelessWidget {
  const _GameBand({required this.colors});

  final FlowColors colors;

  static const _offsets = [
    Alignment(-0.9, -0.6),
    Alignment(0.7, -0.8),
    Alignment(0.95, 0.5),
    Alignment(-0.6, 0.9),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          for (final offset in _offsets)
            Align(
              alignment: offset,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.particle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `13 §14.1`: onboarding titles use `type.pixelTitle`, with an Inter
/// fallback above 130% text scale — `Press Start 2P` becomes illegible
/// (and its fixed metrics start clipping) at large accessibility
/// text-scale settings in a way `type.headline`'s resizable Inter
/// metrics do not.
TextStyle onboardingTitleStyle(BuildContext context) {
  final typography = Theme.of(context).extension<FlowTypography>()!;
  final scale = MediaQuery.textScalerOf(context).scale(1.0);
  return scale > 1.3 ? typography.headline : typography.pixelTitle;
}
