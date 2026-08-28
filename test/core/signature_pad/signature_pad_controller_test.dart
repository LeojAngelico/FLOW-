import 'dart:ui';

import 'package:flow/core/signature_pad/signature_pad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignaturePadController', () {
    test('a fresh pad is empty and has no signature', () {
      final controller = SignaturePadController();

      expect(controller.isEmpty, isTrue);
      expect(controller.hasSignature, isFalse);
      expect(controller.signatureBounds(), isNull);

      controller.dispose();
    });

    test('a tap leaves a mark but is not a signature', () {
      final controller = SignaturePadController();

      controller.startStroke(const Offset(20, 20));

      // Deliberately distinct states: there is ink on the pad, so
      // Clear is worth offering, but Complete is not.
      expect(controller.isEmpty, isFalse);
      expect(controller.hasSignature, isFalse);

      controller.dispose();
    });

    test('a twitch shorter than the ink threshold is not a signature', () {
      final controller = SignaturePadController();

      controller.startStroke(const Offset(20, 20));
      controller.extendStroke(const Offset(24, 22));

      expect(controller.hasSignature, isFalse);

      controller.dispose();
    });

    test('real pen travel counts as a signature', () {
      final controller = SignaturePadController();

      controller.startStroke(const Offset(20, 20));

      for (var i = 1; i <= 10; i++) {
        controller.extendStroke(Offset(20 + i * 5, 20 + i * 2));
      }

      expect(controller.hasSignature, isTrue);

      controller.dispose();
    });

    test('ink accumulates across separate strokes', () {
      final controller = SignaturePadController();

      // Two short marks that individually fall under the threshold.
      controller.startStroke(const Offset(10, 10));
      controller.extendStroke(const Offset(22, 10));

      expect(controller.hasSignature, isFalse);

      controller.startStroke(const Offset(40, 10));
      controller.extendStroke(const Offset(55, 10));

      expect(controller.strokes.length, 2);
      expect(controller.hasSignature, isTrue);

      controller.dispose();
    });

    test('clear removes every stroke and resets the state', () {
      final controller = SignaturePadController();

      controller.startStroke(const Offset(20, 20));
      controller.extendStroke(const Offset(80, 60));

      expect(controller.hasSignature, isTrue);

      controller.clear();

      expect(controller.isEmpty, isTrue);
      expect(controller.hasSignature, isFalse);
      expect(controller.strokes, isEmpty);
      expect(controller.signatureBounds(), isNull);

      controller.dispose();
    });

    test('notifies on every change so the pen keeps up', () {
      final controller = SignaturePadController();

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.startStroke(const Offset(10, 10));
      controller.extendStroke(const Offset(20, 20));
      controller.extendStroke(const Offset(30, 30));
      controller.clear();

      expect(notifications, 4);

      // Clearing an empty pad is not a change.
      controller.clear();
      expect(notifications, 4);

      controller.dispose();
    });

    test('bounds include the pen width so a cap is never clipped', () {
      final controller = SignaturePadController(strokeWidth: 10);

      controller.startStroke(const Offset(50, 50));
      controller.extendStroke(const Offset(100, 80));

      final bounds = controller.signatureBounds()!;

      // Half the stroke width on every side of the raw points.
      expect(bounds.left, 45);
      expect(bounds.top, 45);
      expect(bounds.right, 105);
      expect(bounds.bottom, 85);

      controller.dispose();
    });

    test('exposed strokes cannot be mutated from outside', () {
      final controller = SignaturePadController();

      controller.startStroke(const Offset(10, 10));

      expect(
        () => controller.strokes.add(
          const SignatureStroke(
            points: [Offset.zero],
            color: Color(0xFF000000),
            width: 1,
          ),
        ),
        throwsUnsupportedError,
      );

      controller.dispose();
    });

    test('a move before any pen-down starts a stroke rather than crashing', () {
      final controller = SignaturePadController();

      controller.extendStroke(const Offset(10, 10));

      expect(controller.strokes.length, 1);

      controller.dispose();
    });
  });

  group('SignatureStroke', () {
    test('length is the distance travelled, not the sample count', () {
      const stroke = SignatureStroke(
        points: [Offset(0, 0), Offset(3, 4), Offset(3, 14)],
        color: Color(0xFF000000),
        width: 2,
      );

      // 5 + 10, by Pythagoras and then straight down.
      expect(stroke.length, 15);
    });

    test('a single point has no length and no travel', () {
      const stroke = SignatureStroke(
        points: [Offset(5, 5)],
        color: Color(0xFF000000),
        width: 2,
      );

      expect(stroke.length, 0);
      expect(stroke.bounds, const Rect.fromLTRB(4, 4, 6, 6));
    });
  });
}
