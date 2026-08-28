import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// One image for the viewer to show, and where it comes from.
///
/// A thin wrapper over Flutter's own [ImageProvider] rather than a new
/// image model: the project's `Avatar` is an API DTO (paths a server
/// returned), not something a widget can render, and inventing a
/// parallel abstraction would mean converting between three things
/// instead of two. Callers turn whatever they have into one of these:
///
/// ```dart
/// AppImageSource.network(incident.image.fullPath)
/// AppImageSource.file(result.imagePath)          // a face capture
/// AppImageSource.memory(bytes)
/// AppImageSource.asset('assets/logo.png')
/// ```
///
/// [provider] is the escape hatch: any `ImageProvider` works, so a
/// project that later adds a caching package can pass its provider
/// without touching the viewer.
@immutable
class AppImageSource {
  /// What actually loads the pixels.
  final ImageProvider image;

  /// Announced by screen readers in place of the image.
  final String? semanticLabel;

  /// Matching tag for a [Hero] transition from the thumbnail that
  /// opened the viewer. Optional — the viewer works without it.
  final Object? heroTag;

  const AppImageSource.provider(this.image, {this.semanticLabel, this.heroTag});

  /// An image from a URL.
  ///
  /// [headers] covers the common case of images behind an
  /// authenticated endpoint.
  factory AppImageSource.network(
    String url, {
    Map<String, String>? headers,
    String? semanticLabel,
    Object? heroTag,
  }) {
    return AppImageSource.provider(
      NetworkImage(url, headers: headers),
      semanticLabel: semanticLabel,
      heroTag: heroTag,
    );
  }

  /// An image from a file on the device — a camera capture, say.
  factory AppImageSource.file(
    String path, {
    String? semanticLabel,
    Object? heroTag,
  }) {
    return AppImageSource.provider(
      FileImage(File(path)),
      semanticLabel: semanticLabel,
      heroTag: heroTag,
    );
  }

  /// An image already in memory.
  factory AppImageSource.memory(
    Uint8List bytes, {
    String? semanticLabel,
    Object? heroTag,
  }) {
    return AppImageSource.provider(
      MemoryImage(bytes),
      semanticLabel: semanticLabel,
      heroTag: heroTag,
    );
  }

  /// A bundled asset.
  factory AppImageSource.asset(
    String name, {
    String? semanticLabel,
    Object? heroTag,
  }) {
    return AppImageSource.provider(
      AssetImage(name),
      semanticLabel: semanticLabel,
      heroTag: heroTag,
    );
  }
}
