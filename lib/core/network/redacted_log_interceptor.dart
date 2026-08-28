import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// HTTP request/response logging that never prints sensitive values.
///
/// Replaces Dio's built-in `LogInterceptor`, which has no redaction
/// support and would otherwise print the raw `Authorization` header
/// and any token fields in response bodies verbatim.
///
/// [logHeaders]/[logBody] control verbosity (see
/// `AppEnvironment.logLevel`: verbose logs both, moderate logs
/// neither — just method/URL/status — and minimal skips this
/// interceptor entirely).
class RedactedLogInterceptor extends Interceptor {
  final bool logHeaders;
  final bool logBody;

  RedactedLogInterceptor({this.logHeaders = true, this.logBody = true});

  static const _sensitiveKeys = [
    'authorization',
    'token',
    'password',
    'access_token',
    'refresh_token',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');

    if (logHeaders && options.headers.isNotEmpty) {
      debugPrint('  headers: ${_redact(options.headers)}');
    }

    if (logBody && options.data != null) {
      debugPrint('  body: ${_redact(options.data)}');
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');

    if (logBody) {
      debugPrint('  body: ${_redact(response.data)}');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✗ ${err.requestOptions.method} '
      '${err.requestOptions.uri}: ${err.message}',
    );

    handler.next(err);
  }

  dynamic _redact(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final isSensitive = _sensitiveKeys.any(
          (sensitive) => key.toString().toLowerCase().contains(sensitive),
        );

        return MapEntry(key, isSensitive ? '***REDACTED***' : _redact(value));
      });
    }

    if (data is List) {
      return data.map(_redact).toList();
    }

    return data;
  }
}
