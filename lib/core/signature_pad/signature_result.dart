import 'dart:typed_data';

/// A completed signature, handed back to the calling feature.
///
/// [bytes] is a **PNG with a transparent background containing only
/// the signature strokes** — no pad UI, no border, no instruction text,
/// no background fill. That is the whole point of the component, and
/// it is guaranteed by construction: the export paints the same stroke
/// painter used on screen onto a fresh, empty canvas, rather than
/// screenshotting the widget tree.
///
/// Treat it as sensitive user data. The Core capability never uploads,
/// stores or logs it — what happens next is the feature's decision.
class SignatureResult {
  /// The transparent PNG.
  final Uint8List bytes;

  /// Pixel dimensions of [bytes]. Larger than the on-screen signing
  /// area by the export pixel ratio.
  final int width;
  final int height;

  const SignatureResult({
    required this.bytes,
    required this.width,
    required this.height,
  });

  /// Deliberately omits the bytes — a signature is not something to
  /// drop into a log line.
  @override
  String toString() => 'SignatureResult(${width}x$height, PNG)';
}
