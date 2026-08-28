import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flow/core/face_capture/detection/face_capture_detector.dart';
import 'package:flow/core/face_capture/face_capture_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  group('FaceCaptureConfig', () {
    test('holds the pose for three seconds by default', () {
      expect(
        const FaceCaptureConfig().holdDuration,
        const Duration(seconds: 3),
      );
    });
  });

  // Regression guard for a bug that made the readiness score stall at
  // 50% on iPhone: the frame's dimensions were swapped on iOS as well
  // as Android, which scaled every measurement by the frame's aspect
  // ratio. The face then read as "too close" and off-centre no matter
  // where the user put it, so distance and position could never pass.
  group('FaceCaptureDetector.uprightImageSize', () {
    const landscapeFrame = Size(1280, 720);
    const portraitFrame = Size(720, 1280);

    test('Android swaps a quarter-turned frame', () {
      // ML Kit rotates the frame itself and reports coordinates in the
      // upright result, so the dimensions swap with it.
      for (final rotation in [
        InputImageRotation.rotation90deg,
        InputImageRotation.rotation270deg,
      ]) {
        expect(
          FaceCaptureDetector.uprightImageSize(
            frameSize: landscapeFrame,
            rotation: rotation,
            platform: TargetPlatform.android,
          ),
          portraitFrame,
          reason: rotation.name,
        );
      }
    });

    test('Android leaves an unrotated frame alone', () {
      for (final rotation in [
        InputImageRotation.rotation0deg,
        InputImageRotation.rotation180deg,
      ]) {
        expect(
          FaceCaptureDetector.uprightImageSize(
            frameSize: landscapeFrame,
            rotation: rotation,
            platform: TargetPlatform.android,
          ),
          landscapeFrame,
          reason: rotation.name,
        );
      }
    });

    test('iOS never swaps — the frame already arrives upright', () {
      // AVFoundation applies videoOrientation to the video data
      // output, so a portrait phone streams a portrait buffer.
      for (final rotation in InputImageRotation.values) {
        expect(
          FaceCaptureDetector.uprightImageSize(
            frameSize: portraitFrame,
            rotation: rotation,
            platform: TargetPlatform.iOS,
          ),
          portraitFrame,
          reason: rotation.name,
        );
      }
    });

    test('a frame that is already upright is never made landscape', () {
      // The specific failure that shipped: an upright 720x1280 frame
      // being reported as 1280x720.
      final resolved = FaceCaptureDetector.uprightImageSize(
        frameSize: portraitFrame,
        rotation: InputImageRotation.rotation90deg,
        platform: TargetPlatform.iOS,
      );

      expect(resolved.width, lessThan(resolved.height));
    });
  });

  // Which way the head turned is decided by the sign of the yaw, and
  // that sign depends on whether the analysed frame is mirrored.
  // Getting it wrong makes "turn left" do exactly the opposite, which
  // is what happened on Android after it was fixed for iOS.
  group('frame mirroring and the yaw sign', () {
    test('only the iOS front camera delivers a mirrored frame', () {
      // camera_avfoundation sets isVideoMirrored on the front
      // connection; Android's CameraX mirrors nothing.
      expect(
        FaceCaptureDetector.isAnalysedFrameMirrored(
          platform: TargetPlatform.iOS,
          lensDirection: CameraLensDirection.front,
        ),
        isTrue,
      );

      expect(
        FaceCaptureDetector.isAnalysedFrameMirrored(
          platform: TargetPlatform.iOS,
          lensDirection: CameraLensDirection.back,
        ),
        isFalse,
      );

      expect(
        FaceCaptureDetector.isAnalysedFrameMirrored(
          platform: TargetPlatform.android,
          lensDirection: CameraLensDirection.front,
        ),
        isFalse,
      );

      expect(
        FaceCaptureDetector.isAnalysedFrameMirrored(
          platform: TargetPlatform.android,
          lensDirection: CameraLensDirection.back,
        ),
        isFalse,
      );
    });

    test('the sign is inverted exactly when the frame is mirrored', () {
      double signFor(TargetPlatform platform, CameraLensDirection lens) {
        return FaceCaptureDetector.yawSignForUserLeft(
          platform: platform,
          lensDirection: lens,
        );
      }

      expect(signFor(TargetPlatform.iOS, CameraLensDirection.front), -1);
      expect(signFor(TargetPlatform.iOS, CameraLensDirection.back), 1);
      expect(signFor(TargetPlatform.android, CameraLensDirection.front), 1);
      expect(signFor(TargetPlatform.android, CameraLensDirection.back), 1);
    });

    test('both devices agree once the sign is applied', () {
      // Measured: turning to the user's own left reads about -29° on an
      // iPhone front camera and +29° on an Android one. After the sign
      // both must come out positive, because positive means "the user's
      // own left" everywhere downstream.
      const rawOnIphone = -29.0;
      const rawOnAndroid = 29.0;

      final iphone =
          rawOnIphone *
          FaceCaptureDetector.yawSignForUserLeft(
            platform: TargetPlatform.iOS,
            lensDirection: CameraLensDirection.front,
          );

      final android =
          rawOnAndroid *
          FaceCaptureDetector.yawSignForUserLeft(
            platform: TargetPlatform.android,
            lensDirection: CameraLensDirection.front,
          );

      expect(iphone, 29);
      expect(android, 29);
      expect(iphone.sign, android.sign);
    });
  });

  group('preferredImageFormat', () {
    test('asks for the single-plane format each platform needs', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      expect(FaceCaptureDetector.preferredImageFormat.name, 'nv21');

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(FaceCaptureDetector.preferredImageFormat.name, 'bgra8888');
    });
  });
}
