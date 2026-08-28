import 'dart:ui';

import 'package:flow/core/qr_scanner/widgets/qr_scanner_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrScannerOverlay.frameFor', () {
    test('is a centered square sized from the shorter side', () {
      final frame = QrScannerOverlay.frameFor(const Size(400, 800), 0.5);

      expect(frame.width, 200);
      expect(frame.height, 200);
      expect(frame.center, const Offset(200, 400));
    });

    test('never takes more than half the height', () {
      // A very wide/short surface (landscape): the factor would ask for
      // 480, but the copy above the frame still needs room.
      final frame = QrScannerOverlay.frameFor(const Size(800, 400), 0.9);

      expect(frame.height, 200);
      expect(frame.width, 200);
    });

    test('scales with the size factor', () {
      final small = QrScannerOverlay.frameFor(const Size(400, 800), 0.5);
      final large = QrScannerOverlay.frameFor(const Size(400, 800), 0.9);

      expect(large.width, greaterThan(small.width));
    });
  });
}
