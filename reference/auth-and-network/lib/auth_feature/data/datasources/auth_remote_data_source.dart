import 'package:flutter/cupertino.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/general_response.dart';

import '../models/auth_models.dart';
import '../models/profile_response.dart';
import '../models/register_request.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSource(this.apiClient);

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AppConstants.loginEndpoint,
      data: {'email': email, 'password': password},
    );

    return LoginResponseDto.fromJson(response.data!);
  }

  Future<RefreshTokenResponseDto> refreshToken() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AppConstants.refreshTokenEndpoint,
    );

    return RefreshTokenResponseDto.fromJson(response.data!);
  }

  Future<GeneralResponseDto> register({
    required RegisterRequestDto request,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AppConstants.registerEndpoint,
      data: request.toJson(),
    );

    return GeneralResponseDto.fromJson(response.data!);
  }

  Future<ProfileResponseDto> getProfile() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      AppConstants.profileEndpoint,
    );

    return ProfileResponseDto.fromJson(response.data!);
  }

  Future<GeneralResponseDto> logout() async {
    debugPrint('🟤 REMOTE: logout() called.');

    debugPrint('🟤 REMOTE: Sending POST /api/auth/logout.json...');

    final response = await apiClient.post<Map<String, dynamic>>(
      AppConstants.logoutEndpoint,
    );

    debugPrint('🟢 REMOTE: API response received.');

    debugPrint('🟢 REMOTE: HTTP status = ${response.statusCode}');

    debugPrint('🟢 REMOTE: Response data = ${response.data}');

    return GeneralResponseDto.fromJson(response.data!);
  }
}
