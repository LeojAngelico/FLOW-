import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reduce_motion_provider.dart';

/// Wrap the app's root content in this widget once, near `MaterialApp`,
/// so `reduceMotionProvider` always reflects the OS setting.
class ReduceMotionListener extends ConsumerStatefulWidget {
  const ReduceMotionListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReduceMotionListener> createState() =>
      _ReduceMotionListenerState();
}

class _ReduceMotionListenerState extends ConsumerState<ReduceMotionListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = MediaQuery.of(context).disableAnimations;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(reduceMotionProvider.notifier).sync(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
