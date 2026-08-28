import '../../../../core/storage/secure_storage_service.dart';

class AuthLocalDataSource {
  final SecureStorageService storage;

  const AuthLocalDataSource(this.storage);

  Future<void> saveAccessToken(String token) {
    return storage.saveAccessToken(token);
  }

  Future<String?> getAccessToken() {
    return storage.getAccessToken();
  }

  Future<void> clearTokens() {
    return storage.clearTokens();
  }
}
