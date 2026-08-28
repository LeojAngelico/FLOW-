import 'package:flutter/material.dart';

/// Reusable date picker utility.
///
/// Keeps date picker configuration in one place
/// so it can be reused across features/projects.
class AppDatePicker {
  AppDatePicker._();

  static Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? now,
    );
  }
}
