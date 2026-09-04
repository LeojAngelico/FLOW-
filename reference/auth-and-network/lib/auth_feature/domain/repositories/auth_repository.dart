import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  Future<void> register({
    required String firstName,
    required String lastName,
    required String middleName,
    required String username,
    required String email,
    required String password,
  });

  Future<User> getProfile();

  Future<void> refreshToken();

  Future<void> logout();
}
