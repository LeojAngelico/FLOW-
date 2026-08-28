/// Core QR Scanner — a reusable, feature-agnostic scanner that returns
/// the raw value of the code it read and nothing else. Import this
/// single file to use it.
///
/// ```dart
/// final result = await AppQrScanner.scan(context);
/// ```
library;

export 'app_qr_scanner.dart';
export 'qr_scan_session.dart';
export 'qr_scanner_config.dart';
export 'qr_scanner_page.dart';
