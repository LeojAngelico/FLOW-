import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';

import '../../domain/models/user.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';

import 'profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfileUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  ProfileState build() {
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);

    _logoutUseCase = ref.read(logoutUseCaseProvider);

    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final User user = await _getProfileUseCase.execute();

      state = ProfileState(isLoading: false, user: user);
    } catch (error) {
      final failure = error is Failure ? error : const UnknownFailure();

      state = ProfileState(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _logoutUseCase.execute();

      // We don't navigate here.
      //
      // AuthSessionNotifier is responsible for
      // determining whether the application is
      // authenticated or not.
    } catch (error) {
      final failure = error is Failure ? error : const UnknownFailure();

      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
