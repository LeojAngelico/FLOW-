import 'package:flutter/widgets.dart';

/// Customization for one signing session.
///
/// Every field has a usable default, so the common case is
/// `AppSignaturePad.show(context)`. Low-level rendering (stroke caps,
/// joins, smoothing) is deliberately not exposed — a signature should
/// look the same everywhere in an app.
@immutable
class SignaturePadConfig {
  /// Heading above the signing area. Defaults to the localized
  /// "Sign your signature below".
  final String? title;

  /// Faint placeholder inside an empty signing area. Defaults to the
  /// localized "Sign here"; pass an empty string to hide it.
  final String? hint;

  /// Ink colour. Defaults to a near-black ink rather than pure black,
  /// which reads as slightly softer against white paper.
  final Color strokeColor;

  /// Pen width in logical pixels.
  final double strokeWidth;

  /// Resolution multiplier for the exported PNG.
  ///
  /// Fixed rather than taken from the device so the same signature
  /// exports at the same quality on every phone. 3× a full-width
  /// signing area is comfortably enough for print and PDF embedding.
  final double exportPixelRatio;

  /// Whether to crop the export to the signature's own bounds.
  ///
  /// On by default: a signature drawn in the corner of a tall canvas
  /// would otherwise export as mostly empty space, which is awkward to
  /// composite into a document. Turn it off to keep the full signing
  /// area — still transparent, just uncropped.
  final bool cropToSignature;

  /// Transparent margin kept around the strokes when cropping, in
  /// logical pixels. Stops a signature from touching the very edge of
  /// the image.
  final double cropPadding;

  /// Whether closing with an unsaved signature asks first.
  ///
  /// On by default because a signature is user *work*, and losing it
  /// to a misplaced tap is the kind of thing people notice. Set false
  /// for a pad that closes immediately.
  final bool confirmDiscard;

  /// Labels for the two actions, if the defaults don't fit.
  final String? clearLabel;
  final String? completeLabel;

  const SignaturePadConfig({
    this.title,
    this.hint,
    this.strokeColor = const Color(0xFF1B1B29),
    this.strokeWidth = 3,
    this.exportPixelRatio = 3,
    this.cropToSignature = true,
    this.cropPadding = 12,
    this.confirmDiscard = true,
    this.clearLabel,
    this.completeLabel,
  }) : assert(strokeWidth > 0, 'strokeWidth must be positive.'),
       assert(exportPixelRatio > 0, 'exportPixelRatio must be positive.'),
       assert(cropPadding >= 0, 'cropPadding cannot be negative.');
}
