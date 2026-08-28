import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_sample.dart';
import 'face_surface_projection.dart';

/// Runs on-device face detection over camera frames.
///
/// Owns the ML Kit detector and the frame conversion, and hands back
/// [FaceSample]s — normalized, ML-free values. Everything about this is
/// local to the device: no frame is uploaded, nothing is stored, and no
/// identity is computed. It answers "is there a face, where, facing
/// where, smiling?" and nothing else.
class FaceCaptureDetector {
  /// Android's device-orientation compensation table.
  static const Map<DeviceOrientation, int> _rotationCompensation = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final FaceDetector _detector;

  /// Landmarks and classification are both switched on, always.
  ///
  /// This is not a nicety: on iOS ML Kit only reports head pose when
  /// one of those modes is active — `MLKFace.hasHeadEulerAngleY` is
  /// otherwise false and the plugin sends null. With both off, a null
  /// yaw made every front capture pass without ever checking the pose,
  /// while left and right could never pass at all. Head pose is the
  /// core of this feature, so it is not something to trade for a few
  /// milliseconds a frame.
  FaceCaptureDetector()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          // "fast" is the right trade-off for a live preview; accurate
          // mode roughly doubles per-frame cost for detail this
          // feature does not use.
          performanceMode: FaceDetectorMode.fast,
          // Ignore faces smaller than this share of the frame — people
          // in the background behind the user.
          minFaceSize: 0.15,
        ),
      );

  /// Whether the frame handed to ML Kit is a mirror image of the
  /// subject.
  ///
  /// This is the difference between "turn left" working and doing the
  /// exact opposite, so it is worth stating precisely.
  /// `camera_avfoundation` sets `connection.isVideoMirrored = true` for
  /// the front camera, so on iOS the *buffer* is flipped to match what
  /// the preview shows. Android's CameraX hands over the raw sensor
  /// frame and mirrors nothing.
  ///
  /// A mirrored frame reverses the sense of the yaw angle: the same
  /// head turn produces the opposite sign.
  @visibleForTesting
  static bool isAnalysedFrameMirrored({
    required TargetPlatform platform,
    required CameraLensDirection lensDirection,
  }) {
    return platform == TargetPlatform.iOS &&
        lensDirection == CameraLensDirection.front;
  }

  /// Converts ML Kit's yaw into "positive means the user's own left".
  ///
  /// ML Kit reports `headEulerAngleY` as positive when the face turns
  /// toward the right-hand side of the image. A subject facing the
  /// camera has their own left on the image's right, so in an
  /// unmirrored frame a positive angle already means "turned to their
  /// left" — the documented behaviour, and what Android reports.
  ///
  /// On a mirrored frame (iOS front camera) that same turn arrives
  /// negated, which is why this is derived per frame rather than fixed:
  /// an iPhone front camera reports about -29° for a turn that an
  /// Android front camera reports as +29°.
  @visibleForTesting
  static double yawSignForUserLeft({
    required TargetPlatform platform,
    required CameraLensDirection lensDirection,
  }) {
    return isAnalysedFrameMirrored(
          platform: platform,
          lensDirection: lensDirection,
        )
        ? -1
        : 1;
  }

  /// The image format to ask the camera for on this platform.
  ///
  /// ML Kit wants a single-plane buffer: NV21 on Android, BGRA on iOS.
  static ImageFormatGroup get preferredImageFormat {
    return defaultTargetPlatform == TargetPlatform.android
        ? ImageFormatGroup.nv21
        : ImageFormatGroup.bgra8888;
  }

  /// The size of the frame in the coordinate space the detector reports
  /// face boxes in — which is **not** the same on both platforms.
  ///
  /// - **Android** streams the sensor's native landscape buffer. ML Kit
  ///   is given the rotation, rotates the frame itself, and reports
  ///   coordinates in that upright frame — so a quarter turn swaps the
  ///   dimensions.
  /// - **iOS** streams a frame that is already upright: AVFoundation
  ///   applies `videoOrientation` to the video data output, so a
  ///   portrait phone delivers a portrait buffer. The ML Kit plugin
  ///   also ignores the rotation metadata on iOS (it builds a `UIImage`
  ///   with `.up` orientation), which is consistent with that. Swapping
  ///   here would scale every measurement by the frame's aspect ratio,
  ///   pushing the face out of the guide and the readiness score into a
  ///   ceiling it can never pass.
  @visibleForTesting
  static Size uprightImageSize({
    required Size frameSize,
    required InputImageRotation rotation,
    required TargetPlatform platform,
  }) {
    final isQuarterTurn =
        rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    if (platform != TargetPlatform.android || !isQuarterTurn) {
      return frameSize;
    }

    return Size(frameSize.height, frameSize.width);
  }

  /// Detects faces in one camera frame.
  ///
  /// [surfaceSize] is the logical size of the on-screen preview, used
  /// to express the result in what-the-user-sees coordinates.
  /// Returns an empty sample when the frame can't be interpreted.
  Future<FaceSample> process({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
    required Size surfaceSize,
  }) async {
    final inputImage = _toInputImage(
      image: image,
      camera: camera,
      deviceOrientation: deviceOrientation,
    );

    if (inputImage == null) {
      return const FaceSample.empty();
    }

    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) {
      return const FaceSample.empty();
    }

    // With more than one face the scanner refuses to guess which one
    // to use, but the count still has to travel so it can say so.
    final largest = faces.reduce((a, b) {
      return _area(a.boundingBox) >= _area(b.boundingBox) ? a : b;
    });

    final imageSize = uprightImageSize(
      frameSize: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: inputImage.metadata!.rotation,
      platform: defaultTargetPlatform,
    );

    final projection = FaceSurfaceProjection(
      imageSize: imageSize,
      surfaceSize: surfaceSize,
      mirrored: camera.lensDirection == CameraLensDirection.front,
    );

    final yaw = largest.headEulerAngleY;

    final yawSign = yawSignForUserLeft(
      platform: defaultTargetPlatform,
      lensDirection: camera.lensDirection,
    );

    return projection.sample(
      faceCount: faces.length,
      bounds: largest.boundingBox,
      yawDegrees: yaw == null ? null : yaw * yawSign,
      smileProbability: largest.smilingProbability,
      noseOffsetFraction: _noseOffsetOf(largest),
    );
  }

  Future<void> close() => _detector.close();

  /// How far the nose sits from the middle of the face box, as a
  /// fraction of the box width — unsigned.
  ///
  /// A second opinion on how far the head has turned, and a necessary
  /// one: ML Kit's yaw saturates well before a real profile does. A
  /// head turned far enough to show an ear can still report ~10°, which
  /// is inside the front tolerance. The nose keeps moving toward the
  /// edge of the box the whole way, so it stays informative where the
  /// angle stops being.
  ///
  /// Deliberately unsigned. Which side the head turned toward comes
  /// from the sign of the yaw, which is reliable even when its
  /// magnitude is not — so there is no second convention to get wrong.
  static double? _noseOffsetOf(Face face) {
    final nose = face.landmarks[FaceLandmarkType.noseBase]?.position;
    final box = face.boundingBox;

    if (nose == null || box.width <= 0) {
      return null;
    }

    return (nose.x - box.center.dx).abs() / box.width;
  }

  static double _area(Rect rect) => rect.width * rect.height;

  InputImage? _toInputImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) {
    final rotation = _rotationOf(
      camera: camera,
      deviceOrientation: deviceOrientation,
    );

    if (rotation == null) {
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw as int);

    // Anything other than the single-plane format requested in
    // [preferredImageFormat] cannot be handed to ML Kit as-is.
    if (format == null || image.planes.length != 1) {
      return null;
    }

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// The rotation ML Kit needs to read the frame upright.
  ///
  /// iOS reports a sensor orientation that already accounts for the
  /// device; Android needs the device orientation folded in, and the
  /// front camera counts the other way because its sensor is mirrored.
  InputImageRotation? _rotationOf({
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      // The frame arrives upright (see uprightImageSize), so there is
      // nothing to rotate. Reporting 0 rather than the sensor
      // orientation also keeps this correct if the plugin ever starts
      // honouring the rotation on iOS, instead of silently rotating an
      // already-upright frame.
      return InputImageRotation.rotation0deg;
    }

    final compensation = _rotationCompensation[deviceOrientation];

    if (compensation == null) {
      return null;
    }

    final rotation = camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + compensation) % 360
        : (camera.sensorOrientation - compensation + 360) % 360;

    return InputImageRotationValue.fromRawValue(rotation);
  }
}
