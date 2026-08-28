import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'signature_pad_config.dart';
import 'signature_result.dart';

/// The Core Signature Pad's entry point — the only thing a feature
/// needs.
///
/// Opens a full-screen pad, lets the user draw, and returns the
/// signature as a **PNG with a transparent background containing only
/// the strokes** — no pad UI, no border, no background fill. Returns
/// null if the user closed it without completing.
///
/// The Core capability never uploads, stores or logs the signature.
///
/// ```dart
/// final result = await AppSignaturePad.show(context);
///
/// if (result == null) {
///   return; // Cancelled.
/// }
///
/// await _uploadSignature(result.bytes);
/// ```
class AppSignaturePad {
  AppSignaturePad._();

  /// The route the pad is registered under in `app_router.dart`.
  static const String routePath = '/signature-pad';

  /// Opens the pad and completes with the signature, or null if the
  /// user cancelled.
  static Future<SignatureResult?> show(
    BuildContext context, {
    SignaturePadConfig config = const SignaturePadConfig(),
  }) {
    return GoRouter.of(context).push<SignatureResult>(routePath, extra: config);
  }
}
