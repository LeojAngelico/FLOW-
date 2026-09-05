import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme/flow_theme.dart';
import '../core/design/theme/reduce_motion_listener.dart';
import '../core/environment/app_environment.dart';
import '../core/time/today_refresh_listener.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final environment = AppEnvironment.current;

    // `TodayRefreshListener` and `ReduceMotionListener` are independent
    // lifecycle listeners over the same subtree — nesting order between
    // them doesn't matter.
    return TodayRefreshListener(
      child: ReduceMotionListener(
        child: MaterialApp.router(
          title: environment.appDisplayName,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: FlowTheme.light,
          darkTheme: FlowTheme.dark,
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
