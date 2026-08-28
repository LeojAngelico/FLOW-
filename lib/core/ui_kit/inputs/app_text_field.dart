import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';

/// The Core UI Kit's text input.
///
/// Covers the common cases (label, hint, error, icons) directly.
/// For anything beyond that, pass [decoration] and it's used as-is
/// instead of the built-in default — the same escape hatch pattern
/// used across the kit rather than exposing every `InputDecoration`
/// property individually.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final String? semanticLabel;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.minLines,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.decoration,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        minLines: obscureText ? 1 : minLines,
        maxLines: obscureText ? 1 : maxLines,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        decoration:
            decoration ??
            InputDecoration(
              labelText: label,
              hintText: hint,
              errorText: errorText,
              alignLabelWithHint: maxLines > 1,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              suffixIcon: suffixIcon,
              border: const OutlineInputBorder(borderRadius: AppRadius.mdAll),
            ),
      ),
    );
  }
}
