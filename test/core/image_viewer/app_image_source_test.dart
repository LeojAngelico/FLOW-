import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flow/core/image_viewer/image_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppImageSource', () {
    test('network sources carry the URL and any headers', () {
      final source = AppImageSource.network(
        'https://example.com/a.jpg',
        headers: const {'Authorization': 'Bearer token'},
      );

      final provider = source.image as NetworkImage;

      expect(provider.url, 'https://example.com/a.jpg');
      // Images behind an authenticated endpoint are the common case.
      expect(provider.headers, containsPair('Authorization', 'Bearer token'));
    });

    test('file, memory and asset sources map to the right providers', () {
      expect(AppImageSource.file('/tmp/a.png').image, isA<FileImage>());
      expect(
        AppImageSource.memory(Uint8List.fromList(base64Decode('AAAA'))).image,
        isA<MemoryImage>(),
      );
      expect(AppImageSource.asset('assets/a.png').image, isA<AssetImage>());
    });

    test('any ImageProvider can be passed straight through', () {
      // The escape hatch: a project that adds a caching package hands
      // its provider over without the viewer knowing about it.
      const provider = AssetImage('assets/cached.png');

      expect(const AppImageSource.provider(provider).image, same(provider));
    });

    test('labels and hero tags survive the factories', () {
      final source = AppImageSource.network(
        'https://example.com/a.jpg',
        semanticLabel: 'A photo of a cat',
        heroTag: 'cat',
      );

      expect(source.semanticLabel, 'A photo of a cat');
      expect(source.heroTag, 'cat');
    });

    test('a source with no label leaves it null for the viewer to fill', () {
      expect(AppImageSource.asset('assets/a.png').semanticLabel, isNull);
    });
  });
}
