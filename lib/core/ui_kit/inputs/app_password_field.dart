import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// A password input with a built-in visibility toggle.
///
/// Thin wrapper over [AppTextField] — exists because every password
/// field in the app was re-implementing the same obscure-text toggle.
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? errorText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String? semanticLabel;

  const AppPasswordField({
    super.key,
    this.controller,
    required this.label,
    this.errorText,
    this.enabled = true,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.semanticLabel,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      errorText: widget.errorText,
      enabled: widget.enabled,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      semanticLabel: widget.semanticLabel,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        onPressed: widget.enabled
            ? () => setState(() => _obscure = !_obscure)
            : null,
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    );
  }
}
