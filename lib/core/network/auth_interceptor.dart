import 'package:dio/dio.dart';

import '../auth/auth_session_manager.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends QueuedInterceptor {
  final AuthSessionManager sessionManager;

  late final Dio _refreshDio;
  Dio? _dio;

  Future<String?>? _refreshFuture;

  AuthInterceptor({required this.sessionManager, required String baseUrl}) {
    // Separate Dio instance used ONLY for refresh.
    //
    // This prevents:
    //
    // normal Dio
    //   ↓
    // interceptor
    //   ↓
    // refresh
    //   ↓
    // interceptor
    //   ↓
    // infinite loop
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

  void attachDio(Dio dio) {
    _dio = dio;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[AppConstants.skipAuthKey] == true) {
      handler.next(options);
      return;
    }

    final token = await sessionManager.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;

    // Only refresh when the API tells us
    // that authentication is no longer valid.
    if (error.response?.statusCode != 401) {
      handler.next(error);
      return;
    }

    // Never refresh the refresh request itself.
    if (request.extra[AppConstants.isRefreshRequestKey] == true) {
      await _handleRefreshFailure();
      handler.next(error);
      return;
    }

    // Prevent infinite retry loops.
    final alreadyRetried =
        request.extra[AppConstants.hasRetriedRequestKey] == true;

    if (alreadyRetried) {
      await _handleRefreshFailure();
      handler.next(error);
      return;
    }

    try {
      final newToken = await _refreshAccessToken();

      if (newToken == null || newToken.isEmpty) {
        await _handleRefreshFailure();
        handler.next(error);
        return;
      }

      request.extra[AppConstants.hasRetriedRequestKey] = true;

      request.headers['Authorization'] = 'Bearer $newToken';

      final dio = _dio;

      if (dio == null) {
        await _handleRefreshFailure();
        handler.next(error);
        return;
      }

      // Retry the ORIGINAL request using
      // the original Dio instance.
      final response = await dio.fetch<dynamic>(request);

      handler.resolve(response);
    } catch (_) {
      await _handleRefreshFailure();
      handler.next(error);
    }
  }

  Future<String?> _refreshAccessToken() {
    // If another request is already refreshing,
    // wait for that same operation.
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _performRefreshAccessToken();

    return _refreshFuture!;
  }

  Future<String?> _performRefreshAccessToken() async {
    try {
      final currentToken = await sessionManager.getToken();

      if (currentToken == null || currentToken.isEmpty) {
        return null;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        AppConstants.refreshTokenEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $currentToken'},
          extra: {AppConstants.isRefreshRequestKey: true},
        ),
      );

      final data = response.data;

      if (data == null) {
        return null;
      }

      final status = data['status'] == true;

      final statusCode = data['status_code'];

      if (!status || statusCode != 'ACCESS_TOKEN_UPDATED') {
        return null;
      }

      final newToken = data['token'];

      if (newToken is! String || newToken.isEmpty) {
        return null;
      }

      await sessionManager.saveToken(newToken);

      return newToken;
    } catch (_) {
      return null;
    } finally {
      // Release the refresh lock.
      _refreshFuture = null;
    }
  }

  Future<void> _handleRefreshFailure() async {
    await sessionManager.clearSession();
  }
}
