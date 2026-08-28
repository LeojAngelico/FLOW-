/// Guards one scanner session so exactly one scanned value is ever
/// handed back to the calling screen.
///
/// The camera keeps detecting the same code many times per second, so
/// without a guard a single QR code in front of the lens would fire the
/// result callback repeatedly — popping the route more than once. This
/// is kept as a plain, framework-free class so the rule is unit
/// testable without a camera.
class QrScanSession {
  bool _isCompleted = false;

  /// Whether a value has already been accepted.
  bool get isCompleted => _isCompleted;

  /// Returns the first usable raw value in [rawValues] and closes the
  /// session, or null when the session is already closed or none of
  /// the values are usable.
  ///
  /// Values are returned exactly as the scanner read them — no
  /// trimming, parsing, or interpretation. Null/empty payloads (a
  /// binary-only barcode, for instance) are skipped rather than
  /// returned as an empty result.
  String? accept(Iterable<String?> rawValues) {
    if (_isCompleted) {
      return null;
    }

    for (final rawValue in rawValues) {
      if (rawValue == null || rawValue.isEmpty) {
        continue;
      }

      _isCompleted = true;

      return rawValue;
    }

    return null;
  }
}
