import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_data_providers.dart';

import '../usecases/get_profile_use_case.dart';
import '../usecases/login_use_case.dart';
import '../usecases/logout_use_case.dart';
import '../usecases/refresh_token_use_case.dart';
import '../usecases/register_use_case.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.read(authRepositoryProvider));
});
