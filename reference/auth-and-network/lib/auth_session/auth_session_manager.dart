import '../storage/secure_storage_service.dart';

class AuthSessionManager {
  final SecureStorageService storage;

  AuthSessionManager(this.storage);

  /// Callback assigned by the AuthSessionNotifier.
  ///
  /// The network layer should NOT directly depend
  /// on the presentation layer.
  Future<void> Function()? _onSessionExpired;

  void setOnSessionExpired(Future<void> Function() callback) {
    _onSessionExpired = callback;
  }

  Future<String?> getToken() {
    return storage.getAccessToken();
  }

  Future<void> saveToken(String token) {
    return storage.saveAccessToken(token);
  }

  Future<void> clearSession() async {
    await storage.clearTokens();

    if (_onSessionExpired != null) {
      await _onSessionExpired!();
    }
  }
}
