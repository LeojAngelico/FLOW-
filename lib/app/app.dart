import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/environment/app_environment.dart';
import '../core/ui_kit/indicators/app_environment_badge.dart';
import '../l10n/generated/app_localizations.dart';
import 'locale/locale_notifier.dart';
import 'locale/unsupported_locale_fallback_delegates.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    final locale = ref.watch(localeNotifierProvider);

    final environment = AppEnvironment.current;

    return MaterialApp.router(
      title: environment.appDisplayName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        const CebFallbackMaterialLocalizationsDelegate(),
        const CebFallbackCupertinoLocalizationsDelegate(),
      ],
      builder: (context, child) {
        // Subtle non-interactive corner ribbon so dev/alpha builds
        // are unmistakable — never shown in prod. Banner is a pure
        // CustomPainter decoration (no Overlay dependency), so it's
        // safe to place here above the routed content.
        if (environment.flavor == AppFlavor.prod || child == null) {
          return child ?? const SizedBox.shrink();
        }

        return AppEnvironmentBadge(
          message: environment.name.toUpperCase(),
          color: environment.flavor == AppFlavor.dev
              ? Colors.blue
              : Colors.deepOrange,
          child: child,
        );
      },
    );
  }
}
