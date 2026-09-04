import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../environment/app_environment.dart';

import 'api_client.dart';
import 'auth_interceptor.dart';
import 'redacted_log_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final sessionManager = ref.read(authSessionManagerProvider);

  final environment = AppEnvironment.current;

  final dio = Dio(
    BaseOptions(
      baseUrl: environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // --------------------------------------------------
  // HTTP LOGGER
  // --------------------------------------------------
  //
  // Verbosity follows the active environment (dev: verbose,
  // alpha: moderate, prod: none). Sensitive fields (tokens,
  // passwords) are always redacted — see RedactedLogInterceptor —
  // regardless of environment.
  switch (environment.logLevel) {
    case AppLogLevel.verbose:
      dio.interceptors.add(RedactedLogInterceptor());
    case AppLogLevel.moderate:
      dio.interceptors.add(
        RedactedLogInterceptor(logHeaders: false, logBody: false),
      );
    case AppLogLevel.minimal:
      break;
  }

  final authInterceptor = AuthInterceptor(
    sessionManager: sessionManager,
    baseUrl: environment.apiBaseUrl,
  );

  // Give the interceptor a reference to
  // the primary Dio instance so it can retry
  // failed requests.
  authInterceptor.attachDio(dio);

  // Authentication interceptor.
  //
  // This handles:
  // - Authorization headers
  // - token expiration
  // - refresh token
  // - retrying failed requests
  dio.interceptors.add(authInterceptor);

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});
