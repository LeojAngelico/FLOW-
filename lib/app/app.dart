import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme/flow_theme.dart';
import '../core/design/theme/reduce_motion_listener.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ReduceMotionListener(
      child: MaterialApp.router(
        routerConfig: router,
        theme: FlowTheme.light,
        darkTheme: FlowTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
