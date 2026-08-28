/// The head orientation a capture is asking for.
///
/// "Left" and "right" are from the *user's* point of view — the same
/// way you would say it out loud to them — not the side of the screen
/// their face moves toward.
enum FaceOrientation { front, left, right }

/// Which physical camera to open.
enum FaceCaptureCamera { front, rear }

/// Customization for a single face capture session.
///
/// Every field has a usable default, so the common case is
/// `AppFaceCapture.capture(context)` — a front-facing, no-smile,
/// front-camera capture. Only options that are realistically useful
/// across projects are exposed; detection thresholds are deliberately
/// not part of this API (see `FaceCaptureThresholds`).
///
/// ```dart
/// const FaceCaptureConfig(
///   orientation: FaceOrientation.left,
///   smileRequired: true,
/// )
/// ```
class FaceCaptureConfig {
  /// The orientation the user is asked to hold.
  final FaceOrientation orientation;

  /// Whether a smile is part of the capture conditions.
  ///
  /// When true, readiness cannot reach 100% until a smile is detected.
  ///
  /// **Applies to a front capture only.** ML Kit reads a smile from a
  /// mouth it can barely see once the head is turned, so requiring one
  /// on a left or right capture would gate the photo on a number that
  /// means nothing. Set it freely — it is honoured where it can be and
  /// ignored where it cannot, and the status panel shows "N/A" so the
  /// user isn't waiting on something that will never pass.
  final bool smileRequired;

  /// The camera to start with. Falls back to whatever the device has
  /// if the requested one is missing.
  final FaceCaptureCamera camera;

  /// Whether the user may flip between front and rear cameras.
  final bool allowCameraSwitch;

  /// Screen title. Defaults to the localized "Face Capture".
  final String? title;

  /// How long every condition must hold before the photo is taken.
  ///
  /// This is what stops a single noisy frame from triggering a capture.
  /// It also fills the last quarter of the readiness ring and drives
  /// the countdown shown under the instruction, so shortening it makes
  /// the whole ending feel faster, not just the wait.
  final Duration holdDuration;

  const FaceCaptureConfig({
    this.orientation = FaceOrientation.front,
    this.smileRequired = false,
    this.camera = FaceCaptureCamera.front,
    this.allowCameraSwitch = true,
    this.title,
    this.holdDuration = const Duration(seconds: 3),
  });

  FaceCaptureConfig copyWith({
    FaceOrientation? orientation,
    bool? smileRequired,
    FaceCaptureCamera? camera,
    bool? allowCameraSwitch,
    String? title,
    Duration? holdDuration,
  }) {
    return FaceCaptureConfig(
      orientation: orientation ?? this.orientation,
      smileRequired: smileRequired ?? this.smileRequired,
      camera: camera ?? this.camera,
      allowCameraSwitch: allowCameraSwitch ?? this.allowCameraSwitch,
      title: title ?? this.title,
      holdDuration: holdDuration ?? this.holdDuration,
    );
  }
}
