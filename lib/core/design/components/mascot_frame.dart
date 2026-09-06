import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/flow_motion.dart';

/// Bloop's emotional pose for a [MascotFrame], one per screen (`13
/// §9.3`). Enum names match the asset suffix in
/// `assets/illustrations/mascot/bloop-<name>.svg` verbatim — every
/// value here already has a shipped asset, so no name mapping table is
/// needed. The `-tight` cropped variants that also ship alongside these
/// are not used by this component; they are available for a future
/// compact context (e.g. a mini Bloop badge) that this pass does not
/// need.
enum MascotPose {
  curious,
  steady,
  drinking,
  encouraging,
  happy,
  celebrating,
  resting,
}

extension on MascotPose {
  String get _asset => 'assets/illustrations/mascot/bloop-$name.svg';
}

/// How much staging a [MascotFrame] draws around Bloop.
enum MascotFrameVariant {
  /// Bloop alone.
  bare,

  /// Bloop standing on `sprite-scale-platform.svg`.
  plinth,

  /// [plinth] plus up to three ambient sparkle/bubble particles.
  plinthAndParticles,
}

/// CMP-43. Bloop, framed for a step's emotional beat: one [MascotPose]
/// per screen, optionally grounded on the `sprite-scale-platform.svg`
/// plinth, optionally with ambient particles.
///
/// [size] bounds Bloop to `13 §14.1`'s 88-120dp range (asserted at
/// construction). **Flag for the developer:** that range and the same
/// section's separate "4dp per art pixel for illustration" rule are in
/// tension for these specific assets — `bloop-steady.svg`'s own art-pixel
/// grid is 44x38, which a literal 4dp/pixel scale would render at
/// 176x152dp, well outside 88-120dp. This component honors the explicit
/// numeric range (it is the one a screen's layout must fit inside) and
/// lets [BoxFit.contain] scale each pose down to it, rather than the
/// pixel-grid rule; flag if the intent was the reverse.
///
/// [reduceMotion] is caller-supplied, per hydration Decisions #23 (no
/// `CMP-*` component reads Riverpod): when true the particles hold
/// still instead of drifting, matching `10 §7`'s "motion is decoration
/// and must be fully removable."
class MascotFrame extends StatelessWidget {
  const MascotFrame({
    required this.pose,
    this.variant = MascotFrameVariant.plinth,
    this.size = 104,
    this.reduceMotion = false,
    super.key,
  }) : assert(size >= 88 && size <= 120, '13 §14.1 bounds Bloop to 88-120dp');

  final MascotPose pose;
  final MascotFrameVariant variant;
  final double size;
  final bool reduceMotion;

  static const _plinthAsset =
      'assets/icons/onboarding/sprite-scale-platform.svg';
  static const _particleAssets = [
    'assets/icons/onboarding/particle-sparkle.svg',
    'assets/icons/onboarding/particle-bubble.svg',
  ];

  // Up to 3 particles (per the file plan), scattered around Bloop's
  // upper corners and lower-left, never overlapping the plinth.
  static const _particleOffsets = [
    Alignment(-0.85, -0.55),
    Alignment(0.9, -0.35),
    Alignment(-0.5, 0.85),
  ];

  @override
  Widget build(BuildContext context) {
    final hasPlinth = variant != MascotFrameVariant.bare;
    final hasParticles = variant == MascotFrameVariant.plinthAndParticles;
    final plinthHeight = size * 0.32;

    return ExcludeSemantics(
      child: SizedBox(
        width: size * 1.3,
        height: hasPlinth ? size + plinthHeight * 0.5 : size,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            if (hasPlinth)
              Positioned(
                bottom: 0,
                child: SvgPicture.asset(_plinthAsset, width: size * 1.1),
              ),
            Positioned(
              bottom: hasPlinth ? plinthHeight * 0.5 : 0,
              child: SizedBox(
                width: size,
                height: size,
                child: SvgPicture.asset(pose._asset, fit: BoxFit.contain),
              ),
            ),
            if (hasParticles)
              for (var i = 0; i < _particleOffsets.length; i++)
                Align(
                  alignment: _particleOffsets[i],
                  child: _Particle(
                    asset: _particleAssets[i % _particleAssets.length],
                    reduceMotion: reduceMotion,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// One ambient sparkle/bubble: a gentle scale + fade loop, or a plain
/// static icon under [reduceMotion].
class _Particle extends StatefulWidget {
  const _Particle({required this.asset, required this.reduceMotion});

  final String asset;
  final bool reduceMotion;

  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FlowMotion.celebrate,
    );
    if (!widget.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _Particle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion && !oldWidget.reduceMotion) {
      _controller.stop();
    } else if (!widget.reduceMotion && oldWidget.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox(
      width: 16,
      height: 16,
      child: SvgPicture.asset(widget.asset),
    );

    if (widget.reduceMotion) {
      return icon;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.85 + (_controller.value * 0.3);
        return Opacity(
          opacity: 0.6 + (_controller.value * 0.4),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: icon,
    );
  }
}
