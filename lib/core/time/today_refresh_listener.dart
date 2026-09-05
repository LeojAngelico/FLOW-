import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'today_provider.dart';

/// Wrap the app's root content in this widget once, near `MaterialApp`,
/// so `todayProvider` reflects the local calendar date even after the
/// process was suspended across local midnight.
///
/// `today_provider.dart`'s own `Timer` is not guaranteed to fire while
/// the app is backgrounded — the OS may suspend it. This widget covers
/// that gap the same way `ReduceMotionListener` covers the OS-setting
/// gap: a `ConsumerStatefulWidget` that pokes a provider from a
/// lifecycle event it observes, `AppLifecycleState.resumed` here rather
/// than a `MediaQuery` dependency change, since that is the actual
/// signal that makes a stale "today" observable (`FR-034`).
class TodayRefreshListener extends ConsumerStatefulWidget {
  const TodayRefreshListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<TodayRefreshListener> createState() =>
      _TodayRefreshListenerState();
}

class _TodayRefreshListenerState extends ConsumerState<TodayRefreshListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(todayProvider);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
