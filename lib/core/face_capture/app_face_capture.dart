import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'face_capture_config.dart';
import 'face_capture_result.dart';

/// The Core Face Capture entry point — the only thing a feature needs.
///
/// Opens an immersive camera screen, guides the user into the requested
/// pose, takes the photo by itself once every condition holds steady,
/// and returns the file. Returns null if the user backs out.
///
/// This is **face detection, not face recognition**: it answers "is
/// there one face, framed, turned this way, smiling?" entirely on the
/// device. It never identifies anyone, never matches against a
/// database, never uploads a frame, and keeps nothing.
///
/// ```dart
/// final result = await AppFaceCapture.capture(
///   context,
///   config: const FaceCaptureConfig(
///     orientation: FaceOrientation.left,
///     smileRequired: true,
///   ),
/// );
///
/// if (result == null) {
///   return; // The user closed the scanner.
/// }
///
/// // result.imagePath is a temp file — copy or discard it.
/// ```
class AppFaceCapture {
  AppFaceCapture._();

  /// The route face capture is registered under in `app_router.dart`.
  static const String routePath = '/face-capture';

  /// Opens the capture screen and completes with the photo, or null if
  /// the user cancelled or the camera could not be used.
  ///
  /// One call captures one pose. Multi-pose workflows (left, then
  /// front, then right) are composed by the calling feature — the Core
  /// capability deliberately has no notion of a sequence.
  static Future<FaceCaptureResult?> capture(
    BuildContext context, {
    FaceCaptureConfig config = const FaceCaptureConfig(),
  }) {
    return GoRouter.of(
      context,
    ).push<FaceCaptureResult>(routePath, extra: config);
  }
}
