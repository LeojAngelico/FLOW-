import 'package:flutter/material.dart';

/// Defines a single item inside the application
/// bottom navigation bar.
///
/// This is intentionally reusable so the same
/// component can be used in other projects.
class AppBottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const AppBottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
