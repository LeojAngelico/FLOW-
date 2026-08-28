import 'dart:ui';

import 'package:flow/core/face_capture/detection/face_surface_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A 720x1280 upright camera frame shown on a 393x852 phone: cover
  // scales to the height and crops the sides.
  const projection = FaceSurfaceProjection(
    imageSize: Size(720, 1280),
    surfaceSize: Size(393, 852),
    mirrored: false,
  );

  group('FaceSurfaceProjection', () {
    test('a face centred in the frame is centred on screen', () {
      final sample = projection.sample(
        faceCount: 1,
        bounds: const Rect.fromLTWH(260, 540, 200, 200),
      );

      expect(sample.centerX, closeTo(0.5, 0.001));
      expect(sample.centerY, closeTo(0.5, 0.001));
    });

    test('face width is expressed against the visible surface', () {
      final sample = projection.sample(
        faceCount: 1,
        bounds: const Rect.fromLTWH(260, 540, 200, 200),
      );

      // 200px at the cover scale (852/1280), over a 393pt surface.
      expect(sample.widthFraction, closeTo(0.339, 0.002));
    });

    test('cropping is accounted for, not ignored', () {
      // A face at the left edge of the image is partly cropped away by
      // cover, so it reads as further left than 0 on screen.
      final sample = projection.sample(
        faceCount: 1,
        bounds: const Rect.fromLTWH(0, 540, 200, 200),
      );

      expect(sample.centerX, lessThan(0.2));

      // Without the crop correction this would be 100/720 = 0.14; the
      // correction makes it smaller still.
      expect(sample.centerX, lessThan(100 / 720));
    });

    test('a mirrored preview flips the horizontal axis', () {
      const mirrored = FaceSurfaceProjection(
        imageSize: Size(720, 1280),
        surfaceSize: Size(393, 852),
        mirrored: true,
      );

      final bounds = const Rect.fromLTWH(160, 540, 200, 200);

      final plain = projection.sample(faceCount: 1, bounds: bounds);
      final flipped = mirrored.sample(faceCount: 1, bounds: bounds);

      expect(flipped.centerX, closeTo(1 - plain.centerX!, 0.001));

      // Vertical position and size are unaffected by mirroring.
      expect(flipped.centerY, closeTo(plain.centerY!, 0.001));
      expect(flipped.widthFraction, closeTo(plain.widthFraction!, 0.001));
    });

    test('a landscape frame on a portrait screen crops horizontally', () {
      const wide = FaceSurfaceProjection(
        imageSize: Size(1280, 720),
        surfaceSize: Size(393, 852),
        mirrored: false,
      );

      // A short, wide frame has to be scaled up until it fills the
      // height, which crops the sides heavily.
      expect(wide.scale, closeTo(852 / 720, 0.0001));

      final sample = wide.sample(
        faceCount: 1,
        bounds: const Rect.fromLTWH(540, 260, 200, 200),
      );

      expect(sample.centerX, closeTo(0.5, 0.001));
      expect(sample.centerY, closeTo(0.5, 0.001));
    });

    test('a degenerate surface yields an empty sample', () {
      const none = FaceSurfaceProjection(
        imageSize: Size(720, 1280),
        surfaceSize: Size.zero,
        mirrored: false,
      );

      final sample = none.sample(
        faceCount: 1,
        bounds: const Rect.fromLTWH(0, 0, 10, 10),
      );

      expect(sample.faceCount, 0);
      expect(sample.centerX, isNull);
    });
  });
}
