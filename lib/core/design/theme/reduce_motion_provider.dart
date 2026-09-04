import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reduce_motion_provider.g.dart';

/// Read once from `MediaQuery.disableAnimations` by [ReduceMotionListener]
/// and consumed by every animated component, per 10-accessibility.md.
/// No animated component exists yet in this foundation pass, but the
/// provider is created now since it's a cross-cutting requirement every
/// future animation must plug into from day one.
@riverpod
class ReduceMotion extends _$ReduceMotion {
  @override
  bool build() => false;

  void sync(bool value) {
    if (state != value) {
      state = value;
    }
  }
}
