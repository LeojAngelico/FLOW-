class AppConstants {
  AppConstants._();

  static const String loginEndpoint = '/api/auth/login.json';

  static const String registerEndpoint = '/api/auth/register.json';

  static const String logoutEndpoint = '/api/auth/logout.json';

  static const String refreshTokenEndpoint = '/api/auth/refresh-token.json';

  static const String accessTokenKey = 'access_token';

  static const String localeKey = 'app_locale';

  // Dio interceptor flags.
  static const String skipAuthKey = 'skip_auth';

  static const String isRefreshRequestKey = 'is_refresh_request';

  static const String hasRetriedRequestKey = 'has_retried_request';

  //profile
  static const String profileEndpoint = '/api/profile/show.json';
}
