import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;

/// The three supported build flavors. Combined with debug/release
/// this yields the six build variants: devDebug, devRelease,
/// alphaDebug, alphaRelease, prodDebug, prodRelease.
enum AppFlavor { dev, alpha, prod }

/// How much a Dio interceptor should log. See
/// `lib/core/network/redacted_log_interceptor.dart`.
enum AppLogLevel { verbose, moderate, minimal }

/// Single source of truth for environment-specific configuration.
///
/// Reads the native `--flavor` value (via Flutter's built-in
/// [appFlavor], populated automatically by the Android product
/// flavor / iOS scheme — no `--dart-define` or custom entry points
/// needed) plus the build mode ([kDebugMode]/[kReleaseMode]) to
/// decide everything environment-dependent in one place, instead of
/// scattering `if (flavor == 'dev')` checks through the app.
///
/// Call [AppEnvironment.initialize] once at startup, then read
/// [AppEnvironment.current] anywhere.
class AppEnvironment {
  final AppFlavor flavor;
  final String name;
  final String apiBaseUrl;
  final String appDisplayName;
  final AppLogLevel logLevel;
  final bool enableUiPlayground;

  const AppEnvironment._({
    required this.flavor,
    required this.name,
    required this.apiBaseUrl,
    required this.appDisplayName,
    required this.logLevel,
    required this.enableUiPlayground,
  });

  static AppEnvironment? _current;

  /// The active environment. Throws if [initialize] hasn't run yet.
  static AppEnvironment get current {
    final env = _current;

    if (env == null) {
      throw StateError(
        'AppEnvironment.initialize() must be called before '
        'AppEnvironment.current is read (call it at the top of main()).',
      );
    }

    return env;
  }

  /// Resolves the active flavor from the native `--flavor` value and
  /// builds the matching [AppEnvironment]. Call once, before runApp.
  static void initialize() {
    _current = _configFor(_resolveFlavor());
  }

  static AppFlavor _resolveFlavor() {
    switch (appFlavor) {
      case 'alpha':
        return AppFlavor.alpha;
      case 'prod':
        return AppFlavor.prod;
      case 'dev':
        return AppFlavor.dev;
      default:
        // No --flavor passed (e.g. a plain `flutter run` without
        // -–flavor, or `flutter test`) — default to dev so local
        // development keeps working without extra flags.
        return AppFlavor.dev;
    }
  }

  static AppEnvironment _configFor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return AppEnvironment._(
          flavor: flavor,
          name: 'Development',
          // TODO: replace with the real dev API base URL once one
          // exists — this is a placeholder, not a real endpoint.
          // See Instructions.md ("Environment Configuration").
          apiBaseUrl: 'https://dev-api.TODO-CONFIGURE.example.com',
          appDisplayName: 'FLOW Dev',
          logLevel: AppLogLevel.verbose,
          enableUiPlayground: _uiPlaygroundFor(flavor),
        );

      case AppFlavor.alpha:
        return AppEnvironment._(
          flavor: flavor,
          name: 'Alpha',
          // TODO: replace with the real alpha/staging API base URL
          // once one exists — this is a placeholder, not a real
          // endpoint. See Instructions.md ("Environment Configuration").
          apiBaseUrl: 'https://alpha-api.TODO-CONFIGURE.example.com',
          appDisplayName: 'FLOW Alpha',
          logLevel: AppLogLevel.moderate,
          enableUiPlayground: _uiPlaygroundFor(flavor),
        );

      case AppFlavor.prod:
        return AppEnvironment._(
          flavor: flavor,
          name: 'Production',
          // TODO: replace with the real production API base URL
          // once one exists — this is a placeholder, not a real
          // endpoint. See Instructions.md ("Environment Configuration").
          apiBaseUrl: 'https://api.TODO-CONFIGURE.example.com',
          appDisplayName: 'FLOW',
          logLevel: AppLogLevel.minimal,
          enableUiPlayground: _uiPlaygroundFor(flavor),
        );
    }
  }

  // devDebug -> enabled, devRelease -> disabled by default,
  // alphaDebug/alphaRelease -> enabled (alpha is for internal QA,
  // including QA on release builds), prod -> always disabled.
  static bool _uiPlaygroundFor(AppFlavor flavor) {
    if (flavor == AppFlavor.prod) {
      return false;
    }

    return kDebugMode || flavor == AppFlavor.alpha;
  }
}
