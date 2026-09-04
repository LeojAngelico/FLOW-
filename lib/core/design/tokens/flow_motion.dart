import 'package:flutter/animation.dart';

/// Motion durations and curves (06-design-system.md §6). Nothing in the
/// app may animate longer than [celebrate] (650ms), and every animated
/// component must consume `reduceMotionProvider` (Task 10) to fall back
/// to an instant change or a short cross-fade.
class FlowMotion {
  FlowMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration celebrate = Duration(milliseconds: 650);
  static const Duration page = Duration(milliseconds: 300);

  static const Curve instantCurve = Curves.easeOut;
  static const Curve fastCurve = Curves.easeOutCubic;
  static const Curve baseCurve = Curves.easeInOutCubic;
  static const Curve slowCurve = Curves.easeOutCubic;
  static const Curve celebrateCurve = Curves.easeOutBack;
}
