import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/tokens/flow_elevation.dart';
import 'package:flow/core/design/tokens/flow_motion.dart';
import 'package:flow/core/design/tokens/flow_radius.dart';
import 'package:flow/core/design/tokens/flow_spacing.dart';

void main() {
  test('FlowSpacing follows the 4dp base scale', () {
    expect(FlowSpacing.xs2, 2);
    expect(FlowSpacing.xs, 4);
    expect(FlowSpacing.sm, 8);
    expect(FlowSpacing.md, 16);
    expect(FlowSpacing.xl3, 32);
    expect(FlowSpacing.xl6, 64);
  });

  test(
    'FlowRadius has the documented scale plus the QuickAddChip exception',
    () {
      expect(FlowRadius.sm, 8);
      expect(FlowRadius.md, 12);
      expect(FlowRadius.lg, 16);
      expect(FlowRadius.xl, 24);
      expect(FlowRadius.pill, 999);
      expect(FlowRadius.quickAddChip, 10);
    },
  );

  test(
    'FlowElevation levels never exceed level3 and each has at least one shadow',
    () {
      expect(FlowElevation.level1, isNotEmpty);
      expect(FlowElevation.level2, isNotEmpty);
      expect(FlowElevation.level3, isNotEmpty);
    },
  );

  test('FlowMotion durations never exceed 650ms', () {
    for (final duration in [
      FlowMotion.instant,
      FlowMotion.fast,
      FlowMotion.base,
      FlowMotion.slow,
      FlowMotion.celebrate,
      FlowMotion.page,
    ]) {
      expect(duration.inMilliseconds, lessThanOrEqualTo(650));
    }
    expect(FlowMotion.celebrate.inMilliseconds, 650);
  });
}
