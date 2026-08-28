import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flow/core/signature_pad/signature_pad.dart';
import 'package:flutter_test/flutter_test.dart';

/// Draws a short diagonal stroke inside a 300x200 canvas.
void _sign(SignaturePadController controller, {Offset origin = Offset.zero}) {
  controller.startStroke(origin + const Offset(60, 60));

  for (var i = 1; i <= 20; i++) {
    controller.extendStroke(origin + Offset(60 + i * 4, 60 + i * 2));
  }
}

/// Reads the raw RGBA pixels back out of an exported PNG.
Future<({int width, int height, ByteData pixels})> _decode(
  Uint8List png,
) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

  final result = (width: image.width, height: image.height, pixels: data!);

  image.dispose();
  codec.dispose();

  return result;
}

int _alphaAt(({int width, int height, ByteData pixels}) image, int x, int y) {
  // RGBA, so alpha is the fourth byte of each pixel.
  return image.pixels.getUint8(((y * image.width) + x) * 4 + 3);
}

bool _hasAnyOpaquePixel(({int width, int height, ByteData pixels}) image) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (_alphaAt(image, x, y) > 0) {
        return true;
      }
    }
  }

  return false;
}

void main() {
  const canvas = Size(300, 200);

  group('export', () {
    testWidgets('produces a PNG with a fully transparent background', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController();
        _sign(controller);

        final result = await controller.export(canvasSize: canvas);

        expect(result, isNotNull);

        final image = await _decode(result!.bytes);

        // The whole point of the component: the corners of the export
        // carry no background whatsoever.
        expect(_alphaAt(image, 0, 0), 0);
        expect(_alphaAt(image, image.width - 1, 0), 0);
        expect(_alphaAt(image, 0, image.height - 1), 0);
        expect(_alphaAt(image, image.width - 1, image.height - 1), 0);

        // And the ink really is in there.
        expect(_hasAnyOpaquePixel(image), isTrue);

        controller.dispose();
      });
    });

    testWidgets('is a PNG, not a JPEG', (tester) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController();
        _sign(controller);

        final result = await controller.export(canvasSize: canvas);

        // PNG magic number. JPEG cannot carry transparency, so the
        // format is part of the contract, not an implementation
        // detail.
        expect(result!.bytes.sublist(0, 8), [
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
        ]);

        controller.dispose();
      });
    });

    testWidgets('crops to the signature rather than the whole canvas', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController();
        _sign(controller);

        final ink = controller.signatureBounds()!;

        const padding = 12.0;
        const pixelRatio = 3.0;

        final result = await controller.export(
          canvasSize: canvas,
          padding: padding,
          pixelRatio: pixelRatio,
        );

        // The stroke spans ~80x40 of a 300x200 canvas, so a cropped
        // export is much smaller than the signing area.
        expect(result!.width, ((ink.width + padding * 2) * pixelRatio).ceil());
        expect(result.height, ((ink.height + padding * 2) * pixelRatio).ceil());
        expect(result.width, lessThan((canvas.width * pixelRatio).ceil()));

        controller.dispose();
      });
    });

    testWidgets('keeps the full canvas when cropping is off', (tester) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController();
        _sign(controller);

        final result = await controller.export(
          canvasSize: canvas,
          crop: false,
          pixelRatio: 2,
        );

        expect(result!.width, (canvas.width * 2).ceil());
        expect(result.height, (canvas.height * 2).ceil());

        // Still transparent, just uncropped.
        final image = await _decode(result.bytes);
        expect(_alphaAt(image, 0, 0), 0);

        controller.dispose();
      });
    });

    testWidgets('never clips a stroke drawn hard against the edge', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController(strokeWidth: 8);

        // A stroke starting at the very origin: the crop region has to
        // include half the pen width plus padding, even though that
        // reaches outside the canvas.
        controller.startStroke(Offset.zero);

        for (var i = 1; i <= 20; i++) {
          controller.extendStroke(Offset(i * 3, i.toDouble()));
        }

        final result = await controller.export(
          canvasSize: canvas,
          padding: 4,
          pixelRatio: 1,
        );

        final image = await _decode(result!.bytes);

        // The first sample sits at (4 + 8/2) = 8 px into the image, so
        // the pen's round cap is fully inside it.
        expect(_hasAnyOpaquePixel(image), isTrue);
        expect(_alphaAt(image, 8, 8), greaterThan(0));

        controller.dispose();
      });
    });

    testWidgets('scales with the export pixel ratio', (tester) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController();
        _sign(controller);

        final low = await controller.export(canvasSize: canvas, pixelRatio: 1);
        final high = await controller.export(canvasSize: canvas, pixelRatio: 3);

        // Quality is device-independent: the ratio is the only thing
        // that decides output resolution.
        expect(high!.width, closeTo(low!.width * 3, 3));

        controller.dispose();
      });
    });

    testWidgets('refuses to export an empty pad', (tester) async {
      await tester.runAsync(() async {
        final controller = SignaturePadController();

        expect(await controller.export(canvasSize: canvas), isNull);

        // A stray tap is not a signature either.
        controller.startStroke(const Offset(10, 10));

        expect(await controller.export(canvasSize: canvas), isNull);

        controller.dispose();
      });
    });
  });
}
