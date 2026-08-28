import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../ui_kit/buttons/app_button.dart';
import '../ui_kit/dialogs/app_confirmation_dialog.dart';
import '../ui_kit/tokens/app_sizing.dart';
import '../ui_kit/tokens/app_spacing.dart';
import 'signature_pad_config.dart';
import 'signature_pad_controller.dart';
import 'signature_result.dart';
import 'widgets/signature_canvas.dart';

/// The Core signature pad screen.
///
/// A full-screen route rather than a dialog or sheet: a signature needs
/// as much width and height as the device can give, and the two
/// existing capability screens (scanner, face capture) are routes too,
/// so system back behaves the same way here.
///
/// Holds no business logic. It produces a PNG and pops with it; what
/// that signature is *for* is the calling feature's concern.
class SignaturePadPage extends StatefulWidget {
  final SignaturePadConfig config;

  const SignaturePadPage({super.key, this.config = const SignaturePadConfig()});

  @override
  State<SignaturePadPage> createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<SignaturePadPage> {
  late final SignaturePadController _controller = SignaturePadController(
    strokeColor: widget.config.strokeColor,
    strokeWidth: widget.config.strokeWidth,
  );

  /// Size of the signing area, captured at layout time and used as the
  /// export canvas when cropping is off.
  Size _canvasSize = Size.zero;

  bool _isExporting = false;

  // Mirrored from the controller so the page can rebuild on state
  // *transitions* rather than on every touch point — the canvas
  // repaints itself, and PopScope needs an up-to-date canPop or the
  // Android back gesture would skip the discard confirmation the close
  // button shows.
  bool _hasSignature = false;
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onStrokesChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStrokesChanged)
      ..dispose();

    super.dispose();
  }

  void _onStrokesChanged() {
    final hasSignature = _controller.hasSignature;
    final isEmpty = _controller.isEmpty;

    if (hasSignature == _hasSignature && isEmpty == _isEmpty) {
      return;
    }

    setState(() {
      _hasSignature = hasSignature;
      _isEmpty = isEmpty;
    });
  }

  bool get _shouldConfirmDiscard {
    return widget.config.confirmDiscard && _hasSignature;
  }

  Future<void> _close() async {
    if (!_shouldConfirmDiscard) {
      context.pop();

      return;
    }

    final loc = AppLocalizations.of(context)!;

    // Reuses the Core confirmation dialog rather than a bespoke one.
    AppConfirmationDialog.show(
      context,
      title: loc.signaturePadDiscardTitle,
      message: loc.signaturePadDiscardMessage,
      confirmLabel: loc.signaturePadDiscardConfirm,
      cancelLabel: loc.cancel,
      isDestructive: true,
      onConfirm: () {
        if (mounted) {
          context.pop();
        }
      },
    );
  }

  Future<void> _complete() async {
    if (!_controller.hasSignature || _isExporting) {
      return;
    }

    setState(() => _isExporting = true);

    SignatureResult? result;

    try {
      result = await _controller.export(
        canvasSize: _canvasSize,
        crop: widget.config.cropToSignature,
        padding: widget.config.cropPadding,
        pixelRatio: widget.config.exportPixelRatio,
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }

    if (!mounted) {
      return;
    }

    // A null result means there was nothing to export, which the
    // disabled button should already have prevented — staying put is
    // better than popping with nothing.
    if (result == null) {
      return;
    }

    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final config = widget.config;

    return PopScope(
      // Android back and the iOS swipe both route through the same
      // confirmation as the close button.
      canPop: !_shouldConfirmDiscard,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_close());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: loc.signaturePadCloseTooltip,
                    iconSize: AppSizing.iconMd,
                    onPressed: () => unawaited(_close()),
                  ),
                ),

                Text(
                  config.title ?? loc.signaturePadTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Takes every pixel left over: a cramped signing area
                // is the fastest way to make signatures look wrong.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _canvasSize = constraints.biggest;

                      return SignatureCanvas(
                        controller: _controller,
                        hint: config.hint ?? loc.signaturePadHint,
                        semanticLabel: loc.signaturePadAreaSemantics,
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: config.clearLabel ?? loc.signaturePadClear,
                        variant: AppButtonVariant.secondary,
                        // Nothing to clear on an empty pad.
                        onPressed: _isEmpty ? null : _controller.clear,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: config.completeLabel ?? loc.signaturePadComplete,
                        isLoading: _isExporting,
                        // Disabled until there is real ink — see
                        // SignaturePadController.minimumInkLength.
                        onPressed: _hasSignature
                            ? () => unawaited(_complete())
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
