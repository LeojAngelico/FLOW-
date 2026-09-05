import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-10. radius.sm, 2dp border, no depth offset (inputs aren't
/// tappable buttons, so no press affordance). Focused uses brandPrimary
/// stroke; Error uses color.error, with the message rendered separately
/// below in caption + error — never color alone.
class FlowTextField extends StatefulWidget {
  const FlowTextField({
    required this.controller,
    this.errorText,
    this.numericHero = false,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool numericHero;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  /// Passed straight through to the underlying [TextField]. Defaults to
  /// `null` (the platform's own default keyboard) so existing callers
  /// are unaffected — only a caller that needs a restricted keyboard
  /// (e.g. a numeric amount field) sets this.
  final TextInputType? keyboardType;

  /// Passed straight through to the underlying [TextField]. Defaults to
  /// `null` (no formatting/filtering) so existing callers are
  /// unaffected. A caller that restricts input this way (e.g.
  /// `FilteringTextInputFormatter.digitsOnly`) never sees a character
  /// its `onChanged` cannot handle in the first place, instead of
  /// receiving it and having to recover from a failed parse.
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<FlowTextField> createState() => _FlowTextFieldState();
}

class _FlowTextFieldState extends State<FlowTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final hasError = widget.errorText != null;

    final Color borderColor;
    if (hasError) {
      borderColor = colors.error;
    } else if (_focused) {
      borderColor = colors.brandPrimary;
    } else {
      borderColor = colors.borderStrong;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(FlowRadius.sm),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            style:
                (widget.numericHero ? typography.numericHero : typography.bodyL)
                    .copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              hintText: widget.hintText,
              hintStyle: typography.bodyL.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(
              top: FlowSpacing.xs,
              left: FlowSpacing.xs,
            ),
            child: Text(
              widget.errorText!,
              style: typography.caption.copyWith(color: colors.error),
            ),
          ),
      ],
    );
  }
}
