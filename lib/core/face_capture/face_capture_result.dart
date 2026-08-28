import 'dart:io';

import 'face_capture_config.dart';

/// What a completed capture hands back to the calling feature.
///
/// Deliberately thin: a file, what was asked for, and when. No
/// landmarks, no probabilities, no identity — the Core capability
/// detects a face, it does not recognize a person.
///
/// [imagePath] points at a **temporary** file created by the camera.
/// The Core capability never moves, copies, uploads, or deletes it —
/// treat it as sensitive data and have the calling feature copy it
/// somewhere it controls (or discard it) as soon as it is done.
class FaceCaptureResult {
  /// Absolute path of the captured JPEG in the app's temp directory.
  final String imagePath;

  /// The orientation that was requested for this capture.
  final FaceOrientation orientation;

  /// The camera the photo came from.
  final FaceCaptureCamera camera;

  /// When the shutter fired.
  final DateTime capturedAt;

  const FaceCaptureResult({
    required this.imagePath,
    required this.orientation,
    required this.camera,
    required this.capturedAt,
  });

  /// The captured image as a [File], for convenience.
  File get file => File(imagePath);

  /// Deliberately omits the path — capture paths are user data and
  /// this may end up in a log.
  @override
  String toString() {
    return 'FaceCaptureResult(orientation: ${orientation.name}, '
        'camera: ${camera.name})';
  }
}
