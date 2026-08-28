import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'signature_result.dart';
import 'signature_stroke.dart';
import 'widgets/signature_painter.dart';

/// Holds the strokes, decides whether they amount to a signature, and
/// exports them.
///
/// A plain [ChangeNotifier] rather than a Riverpod notifier: the
/// strokes are the state of one widget on one screen, they change on
/// every touch frame, and nothing outside the pad has any business
/// reading them. Keeping it framework-light also makes the export
/// testable without pumping a widget.
class SignaturePadController extends ChangeNotifier {
  /// Ink travel below which the marks are treated as an accident
  /// rather than a signature, in logical pixels.
  ///
  /// A tap or a twitch produces almost no travel; even initials
  /// produce far more than this. This is why the pad does not simply
  /// ask "has the canvas been touched?".
  static const double minimumInkLength = 20;

  final Color strokeColor;
  final double strokeWidth;

  SignaturePadController({
    this.strokeColor = const Color(0xFF1B1B29),
    this.strokeWidth = 3,
  });

  final List<SignatureStroke> _strokes = [];

  /// The strokes drawn so far, oldest first.
  List<SignatureStroke> get strokes => List.unmodifiable(_strokes);

  bool get isEmpty => _strokes.isEmpty;

  /// Whether there is enough ink to call this a signature.
  ///
  /// This is what enables Complete.
  bool get hasSignature => _inkLength >= minimumInkLength;

  double get _inkLength {
    return _strokes.fold<double>(0, (total, stroke) => total + stroke.length);
  }

  /// Starts a new stroke at [point] (pen down).
  void startStroke(Offset point) {
    _strokes.add(
      SignatureStroke(points: [point], color: strokeColor, width: strokeWidth),
    );

    notifyListeners();
  }

  /// Extends the current stroke to [point] (pen moving).
  void extendStroke(Offset point) {
    if (_strokes.isEmpty) {
      startStroke(point);

      return;
    }

    _strokes.last.points.add(point);

    notifyListeners();
  }

  /// Removes every stroke. Immediate and repeatable, which is why it
  /// needs no confirmation of its own.
  void clear() {
    if (_strokes.isEmpty) {
      return;
    }

    _strokes.clear();

    notifyListeners();
  }

  /// The area the ink occupies, pen width included, or null if there
  /// is none.
  Rect? signatureBounds() {
    Rect? bounds;

    for (final stroke in _strokes) {
      final strokeBounds = stroke.bounds;

      if (strokeBounds == null) {
        continue;
      }

      bounds = bounds == null
          ? strokeBounds
          : bounds.expandToInclude(strokeBounds);
    }

    return bounds;
  }

  /// Renders the strokes to a transparent PNG.
  ///
  /// Nothing paints a background, so every pixel the pen did not touch
  /// stays fully transparent. The [SignaturePainter] used here is the
  /// same one that drew the preview, so the export cannot drift from
  /// what the user saw — and cannot pick up the pad's border, hint
  /// text or buttons, because those are separate widgets.
  ///
  /// [canvasSize] is the size of the on-screen signing area, used when
  /// cropping is off. Returns null when there is no signature.
  Future<SignatureResult?> export({
    required Size canvasSize,
    bool crop = true,
    double padding = 12,
    double pixelRatio = 3,
  }) async {
    if (!hasSignature) {
      return null;
    }

    final ink = signatureBounds();

    if (ink == null) {
      return null;
    }

    // Cropping is analytic — derived from the stroke geometry, not
    // from scanning pixels for transparency. That is exact, cheap, and
    // cannot clip a stroke: the bounds already include the pen width,
    // and padding is added on top.
    final region = crop
        ? ink.inflate(padding)
        : Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);

    final width = (region.width * pixelRatio).ceil();
    final height = (region.height * pixelRatio).ceil();

    if (width <= 0 || height <= 0) {
      return null;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(pixelRatio);
    // Move the crop region to the origin so the strokes land inside
    // the smaller image.
    canvas.translate(-region.left, -region.top);

    SignaturePainter(strokes: _strokes).paint(canvas, region.size);

    final picture = recorder.endRecording();

    ui.Image? image;

    try {
      image = await picture.toImage(width, height);

      final data = await image.toByteData(format: ui.ImageByteFormat.png);

      if (data == null) {
        return null;
      }

      return SignatureResult(
        bytes: data.buffer.asUint8List(),
        width: width,
        height: height,
      );
    } finally {
      image?.dispose();
      picture.dispose();
    }
  }
}
