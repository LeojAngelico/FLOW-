import 'package:flow/core/qr_scanner/qr_scan_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrScanSession', () {
    test('returns the first usable raw value', () {
      final session = QrScanSession();

      expect(session.accept(['USER-12345']), 'USER-12345');
      expect(session.isCompleted, isTrue);
    });

    test('returns the raw value unchanged', () {
      final session = QrScanSession();

      // Whitespace, casing, and URL structure must survive untouched —
      // the calling feature owns any interpretation.
      const raw = '  https://example.com/user/12345?ref=QR  ';

      expect(session.accept([raw]), raw);
    });

    test('ignores every scan after the first accepted one', () {
      final session = QrScanSession();

      expect(session.accept(['USER-12345']), 'USER-12345');

      // The camera keeps reporting the same code many times a second.
      expect(session.accept(['USER-12345']), isNull);
      expect(session.accept(['USER-12345']), isNull);
      expect(session.accept(['SOMETHING-ELSE']), isNull);
    });

    test('skips null and empty payloads without completing', () {
      final session = QrScanSession();

      expect(session.accept([null, '']), isNull);
      expect(session.isCompleted, isFalse);

      // A later, usable scan still works.
      expect(session.accept([null, '', 'USER-12345']), 'USER-12345');
    });

    test('returns null for an empty capture', () {
      final session = QrScanSession();

      expect(session.accept(const <String?>[]), isNull);
      expect(session.isCompleted, isFalse);
    });
  });
}
