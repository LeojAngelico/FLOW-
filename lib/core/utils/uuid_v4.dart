import 'dart:math';

/// Generates a random RFC 4122 version-4 UUID using [Random.secure].
///
/// Hand-rolled instead of the `uuid` package — see
/// `docs/workplans/2026-09-04-hydration-logging.md` Decisions #6.
/// `pubspec.yaml` has no `uuid` dependency; the only requirement is
/// uniqueness within one device's database, which `Random.secure()`
/// plus v4 formatting satisfies in a few lines.
String newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));

  // Version 4: the 4 most-significant bits of byte 6 are `0100`.
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  // Variant 1 (RFC 4122): the 2 most-significant bits of byte 8 are `10`.
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  String hex(int start, int end) {
    return bytes
        .sublist(start, end)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
