import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Whether a [BrandMark] renders the icon alone or the full lockup.
enum BrandMarkVariant {
  /// `assets/brand/app-icon.svg` alone — a square glyph.
  mark,

  /// `assets/brand/wordmark-lockup.svg` — Bloop and the "FLOW" wordmark
  /// already combined into one asset (its own `aria-label` reads "FLOW
  /// wordmark with Bloop"), so this variant is one `SvgPicture.asset`
  /// call, not two stacked.
  markAndWordmark,
}

/// CMP-20. `ONB-02`'s hero brand mark and the `/` route placeholder.
/// [width] sizes the mark; height follows each asset's own intrinsic
/// aspect ratio (square for [BrandMarkVariant.mark], ~2.5:1 for
/// [BrandMarkVariant.markAndWordmark]) so neither asset is stretched.
/// No dp value is pinned for this by any spec this plan cites — 160dp
/// is this implementer's default; callers needing a different size
/// (e.g. a smaller `/` placeholder) pass their own [width].
class BrandMark extends StatelessWidget {
  const BrandMark({
    this.variant = BrandMarkVariant.markAndWordmark,
    this.width = 160,
    super.key,
  });

  final BrandMarkVariant variant;
  final double width;

  static const _markAsset = 'assets/brand/app-icon.svg';
  static const _lockupAsset = 'assets/brand/wordmark-lockup.svg';

  // wordmark-lockup.svg's own viewBox: 406x162.
  static const _lockupAspectRatio = 406 / 162;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      BrandMarkVariant.mark => SvgPicture.asset(
        _markAsset,
        width: width,
        height: width,
      ),
      BrandMarkVariant.markAndWordmark => SvgPicture.asset(
        _lockupAsset,
        width: width,
        height: width / _lockupAspectRatio,
      ),
    };
  }
}
