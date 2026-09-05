import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_typography.dart';
import 'flow_tappable.dart';

/// Which way a [StepperButton] moves the value.
enum StepDirection { increment, decrement }

/// CMP-23. 64dp − / + control, long-press auto-repeat at 150ms,
/// disabled at bounds. Wraps [FlowTappable] for the button semantics.
///
/// A single tap calls [onStep] exactly once, both for a normal touch
/// tap and for a screen-reader "activate" action (`FlowTappable` wires
/// both to `GestureDetector.onTap`). Holding past a short initial delay
/// begins an additional repeat call every 150ms until release; the
/// pending tap is suppressed in that case so a long press never fires
/// [onStep] twice for the same initial press.
///
/// Bounds are the caller's concern: pass `enabled: false` when stepping
/// further would go outside 50–2,000ml (`FR-024`), and `FlowTappable`
/// disables both the gesture and the semantics action.
///
/// No explicit [FlowTappable] `label` is set — the visible "+"/"−"
/// glyph is a `Text` descendant, which `Semantics` folds into the
/// accessible name automatically, matching every other text-bearing
/// `CMP-*` component in this directory (only icon-only components like
/// `FlowBackButton` need an explicit label). [semanticLabel] is an
/// optional seam for a caller that wants a richer announcement (e.g.
/// "Increase amount") once that copy exists — no `CPY-*` key for it is
/// allocated yet, so this defaults to `null` rather than inventing one.
class StepperButton extends StatefulWidget {
  const StepperButton({
    required this.direction,
    required this.onStep,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final StepDirection direction;
  final VoidCallback onStep;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<StepperButton> {
  static const _initialRepeatDelay = Duration(milliseconds: 400);
  static const _repeatInterval = Duration(milliseconds: 150);

  Timer? _initialDelayTimer;
  Timer? _repeatTimer;
  bool _hasRepeated = false;

  void _handleTapDown(TapDownDetails _) {
    _hasRepeated = false;
    _initialDelayTimer = Timer(_initialRepeatDelay, () {
      // The widget may have been rebuilt disabled (e.g. hitting the
      // 2,000ml cap) while this delay was pending -- see the
      // didUpdateWidget guard below for why this can't rely solely on
      // that callback having already run.
      if (!widget.enabled) {
        _cancelTimers();
        return;
      }
      _hasRepeated = true;
      widget.onStep();
      _repeatTimer = Timer.periodic(_repeatInterval, (_) {
        if (!widget.enabled) {
          _cancelTimers();
          return;
        }
        widget.onStep();
      });
    });
  }

  void _cancelTimers() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void didUpdateWidget(covariant StepperButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // FlowTappable nulls its gesture callbacks entirely when `enabled`
    // goes false, which tears down the tap recognizer without ever
    // calling onTapUp/onTapCancel -- so the auto-repeat timers would
    // otherwise keep firing after the button becomes disabled mid-hold
    // (e.g. hitting the 2,000ml cap while held). The per-callback guards
    // above cover the timers that are already scheduled; this covers
    // the case where disabling happens between two timer firings.
    if (oldWidget.enabled && !widget.enabled) {
      _cancelTimers();
    }
  }

  void _handleTap() {
    // A long press already called onStep at least once via the repeat
    // timer above; the trailing onTap from the same press must not
    // double-count it.
    if (!_hasRepeated) {
      widget.onStep();
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final glyph = widget.direction == StepDirection.increment ? '+' : '−';

    return FlowTappable(
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: (_) => _cancelTimers(),
      onTapCancel: _cancelTimers,
      child: Container(
        key: const ValueKey('stepper-button'),
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.enabled ? colors.surfacePrimary : colors.surfaceAlt,
          border: Border.all(color: colors.frameInk, width: 2),
          borderRadius: BorderRadius.circular(FlowRadius.md),
        ),
        child: Text(
          glyph,
          style: typography.headline.copyWith(
            color: widget.enabled ? colors.textPrimary : colors.textDisabled,
          ),
        ),
      ),
    );
  }
}
