import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The six square footprints [PixelIcon] renders at. Fixed as an enum,
/// not a raw `double`, because `13 §14.1` requires every pixel-art icon
/// to land on an exact 2dp-per-art-pixel scale — a fractional size
/// (e.g. 30dp) would split an art pixel across a sub-pixel boundary and
/// read as blur rather than a crisp edge. The onboarding icon set is
/// authored on a 6-unit grid (verified against `icon-droplet.svg` and
/// its neighbours in `assets/icons/onboarding/`), so a caller aiming
/// for the literal 2dp/art-pixel scale for a given icon should pick the
/// size equal to `2 * (icon's longest edge in art pixels)` — this
/// component does not compute that automatically, since it has no way
/// to introspect an asset's native grid at runtime.
enum PixelIconSize {
  xs(16),
  sm(20),
  md(24),
  lg(32),
  xl(40),
  xxl(48);

  const PixelIconSize(this.dp);

  /// The rendered square footprint, in logical pixels.
  final double dp;
}

/// CMP-42. Renders one pixel-art icon from `assets/icons/onboarding/`
/// inside a fixed square footprint using `BoxFit.contain`, so a
/// non-square source (e.g. `icon-chevron-left.svg`'s 7x11 art-pixel
/// grid) is centered rather than stretched off its own scale. Every
/// other Core component built alongside this one composes through
/// [PixelIcon] rather than calling `SvgPicture.asset` directly, so a
/// future asset swap or recolor touches one file. No Material Symbols
/// anywhere in onboarding — `13 §14.1`.
class PixelIcon extends StatelessWidget {
  const PixelIcon({
    required this.asset,
    this.size = PixelIconSize.md,
    this.color,
    super.key,
  });

  /// A path under `assets/icons/onboarding/`, e.g.
  /// `'assets/icons/onboarding/icon-chevron-left.svg'`.
  final String asset;

  final PixelIconSize size;

  /// Recolors the icon (`ColorFilter.mode(color, BlendMode.srcIn)`).
  /// Leave `null` to keep the asset's own baked-in ink color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.dp,
      height: size.dp,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}
