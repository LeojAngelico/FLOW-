import 'package:mobile_scanner/mobile_scanner.dart';

/// A barcode symbology the Core QR Scanner can be asked to detect.
///
/// Mirrors the subset of the scanner package's formats that is useful
/// in app code, so callers never have to import `mobile_scanner`
/// themselves — swapping the underlying package later only changes the
/// mapping below.
enum QrScanFormat {
  qrCode,
  dataMatrix,
  aztec,
  pdf417,
  ean8,
  ean13,
  upcA,
  upcE,
  code39,
  code93,
  code128,
  itf,
  codabar,
}

/// Customization for a single Core QR Scanner session.
///
/// Every field has a sensible default, so the common case is
/// `AppQrScanner.scan(context)` with no configuration at all. Only
/// options that are realistically useful across projects are exposed —
/// anything beyond this (a different overlay, extra controls) belongs
/// in a copy of `QrScannerPage`, not in another constructor argument.
///
/// ```dart
/// // Scan employee badges, which are Code 128 barcodes.
/// final result = await AppQrScanner.scan(
///   context,
///   config: const QrScannerConfig(
///     instruction: 'Hold the badge inside the frame',
///     formats: {QrScanFormat.code128},
///   ),
/// );
/// ```
class QrScannerConfig {
  /// Heading shown above the scan frame.
  ///
  /// Defaults to the localized "Scan QR code" when null.
  final String? title;

  /// Short instruction shown under the [title].
  ///
  /// Defaults to the localized "Place the markers around the QR
  /// code..." when null.
  final String? instruction;

  /// The symbologies to detect.
  ///
  /// Defaults to QR codes only, so a stray barcode in the frame can't
  /// end the session with a value the caller didn't ask for. Pass an
  /// empty set to accept every format the platform supports.
  final Set<QrScanFormat> formats;

  /// Whether the flashlight toggle is shown.
  ///
  /// The button hides itself anyway on devices that report no torch,
  /// so this is for hiding it by product decision, not by capability.
  final bool showTorchButton;

  /// Size of the square scan frame, as a fraction of the shorter side
  /// of the scanner surface.
  ///
  /// Also drives the scan window: codes outside the frame are ignored.
  final double frameSizeFactor;

  const QrScannerConfig({
    this.title,
    this.instruction,
    this.formats = const {QrScanFormat.qrCode},
    this.showTorchButton = true,
    this.frameSizeFactor = 0.72,
  }) : assert(
         frameSizeFactor > 0 && frameSizeFactor <= 1,
         'frameSizeFactor must be between 0 (exclusive) and 1.',
       );

  /// The [formats] translated for the scanner package.
  ///
  /// An empty list means "every supported format" to `mobile_scanner`.
  List<BarcodeFormat> get barcodeFormats {
    return formats.map(_toBarcodeFormat).toList(growable: false);
  }

  static BarcodeFormat _toBarcodeFormat(QrScanFormat format) {
    switch (format) {
      case QrScanFormat.qrCode:
        return BarcodeFormat.qrCode;
      case QrScanFormat.dataMatrix:
        return BarcodeFormat.dataMatrix;
      case QrScanFormat.aztec:
        return BarcodeFormat.aztec;
      case QrScanFormat.pdf417:
        return BarcodeFormat.pdf417;
      case QrScanFormat.ean8:
        return BarcodeFormat.ean8;
      case QrScanFormat.ean13:
        return BarcodeFormat.ean13;
      case QrScanFormat.upcA:
        return BarcodeFormat.upcA;
      case QrScanFormat.upcE:
        return BarcodeFormat.upcE;
      case QrScanFormat.code39:
        return BarcodeFormat.code39;
      case QrScanFormat.code93:
        return BarcodeFormat.code93;
      case QrScanFormat.code128:
        return BarcodeFormat.code128;
      case QrScanFormat.itf:
        return BarcodeFormat.itf14;
      case QrScanFormat.codabar:
        return BarcodeFormat.codabar;
    }
  }
}
