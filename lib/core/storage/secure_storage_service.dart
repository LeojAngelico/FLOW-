import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveAccessToken(String token) {
    return _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  // Future<void> saveRefreshToken(String token) {
  //   return _storage.write(
  //     key: AppConstants.refreshTokenKey,
  //     value: token,
  //   );
  // }
  //
  // Future<String?> getRefreshToken() {
  //   return _storage.read(
  //     key: AppConstants.refreshTokenKey,
  //   );
  // }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);

    // await _storage.delete(
    //   key: AppConstants.refreshTokenKey,
    // );
  }

  Future<void> saveLocaleCode(String localeCode) {
    return _storage.write(key: AppConstants.localeKey, value: localeCode);
  }

  Future<String?> getLocaleCode() {
    return _storage.read(key: AppConstants.localeKey);
  }
}
