import 'package:flutter/cupertino.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/validation_failure.dart';

import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      if (!response.status) {
        if (response.statusCode == 'UNAUTHORIZED') {
          throw UnauthorizedFailure(response.message);
        }

        throw AuthenticationFailure(response.message);
      }

      // Save the JWT returned by the login API.
      await localDataSource.saveAccessToken(response.token);

      return response.toDomain();
    } catch (error) {
      // Don't remap failures that we already
      // converted into application failures.
      if (error is Failure) {
        rethrow;
      }

      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final response = await remoteDataSource.refreshToken();

      if (!response.status) {
        throw AuthenticationFailure(response.message);
      }

      // Replace the expired/old token with
      // the newly issued access token.
      await localDataSource.saveAccessToken(response.token);
    } catch (error) {
      if (error is Failure) {
        rethrow;
      }

      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String middleName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequestDto(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        username: username,
        email: email,
        password: password,
      );

      final response = await remoteDataSource.register(request: request);

      // Registration succeeded.
      if (response.status) {
        return;
      }

      // The backend returned field-level
      // validation errors.
      if (response.statusCode == 'INVALID_DATA' && response.hasRequirements) {
        throw ValidationFailure(response.message, fieldErrors: response.errors);
      }

      // Generic registration failure.
      throw AuthenticationFailure(response.message);
    } catch (error) {
      // Don't remap failures that we already
      // converted into application failures.
      if (error is Failure) {
        rethrow;
      }

      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<void> logout() async {
    debugPrint('🔵 REPOSITORY: logout() called.');

    try {
      debugPrint('🔵 REPOSITORY: Calling remoteDataSource.logout()...');

      final response = await remoteDataSource.logout();

      debugPrint('🟢 REPOSITORY: Remote logout returned.');

      debugPrint('🟢 REPOSITORY: status = ${response.status}');

      debugPrint('🟢 REPOSITORY: message = ${response.message}');

      debugPrint('🟢 REPOSITORY: statusCode = ${response.statusCode}');

      if (!response.status) {
        debugPrint('❌ REPOSITORY: Logout API returned status=false.');

        throw AuthenticationFailure(response.message);
      }

      debugPrint('🟢 REPOSITORY: Logout API successful.');
    } catch (error, stackTrace) {
      debugPrint('❌ REPOSITORY: Logout API error: $error');

      debugPrint('❌ REPOSITORY STACK TRACE:\n$stackTrace');

      if (error is Failure) {
        rethrow;
      }

      throw ErrorMapper.map(error);
    } finally {
      debugPrint('🟡 REPOSITORY: Clearing local tokens...');

      await localDataSource.clearTokens();

      debugPrint('🟢 REPOSITORY: Local tokens cleared.');
    }
  }

  @override
  Future<User> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();

      if (!response.status) {
        throw AuthenticationFailure(response.message);
      }

      return response.user;
    } catch (error) {
      if (error is Failure) {
        rethrow;
      }

      throw ErrorMapper.map(error);
    }
  }
}
