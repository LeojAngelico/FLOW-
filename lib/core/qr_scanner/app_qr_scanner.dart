import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'qr_scanner_config.dart';

/// The Core QR Scanner's entry point — the only thing a feature needs.
///
/// Opens the scanner, waits for the user, and returns the raw value
/// encoded in the scanned code, or null when the user cancelled. The
/// scanner never interprets the value: validating it, navigating on it,
/// or sending it to an API is the calling feature's job (and its
/// responsibility, since a scanned code is untrusted input).
///
/// ```dart
/// final result = await AppQrScanner.scan(context);
///
/// if (result == null) {
///   return; // The user closed the scanner.
/// }
///
/// // `result` is the exact string the code contained.
/// ```
class AppQrScanner {
  AppQrScanner._();

  /// The route the scanner is registered under in `app_router.dart`.
  ///
  /// Shared with the router so the path is written down once.
  static const String routePath = '/qr-scanner';

  /// Opens the scanner and completes with the scanned value, or null if
  /// the user cancelled or the camera could not be used.
  ///
  /// Pass a [config] to change the copy, the accepted formats, the
  /// frame size, or to hide the flashlight toggle.
  static Future<String?> scan(
    BuildContext context, {
    QrScannerConfig config = const QrScannerConfig(),
  }) {
    return GoRouter.of(context).push<String>(routePath, extra: config);
  }
}
