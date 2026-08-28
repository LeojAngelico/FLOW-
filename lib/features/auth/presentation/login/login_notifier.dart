import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/login_use_case.dart';
import '../session/auth_session_notifier.dart';

import 'login_state.dart';

class LoginNotifier extends Notifier<LoginState> {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    // Get LoginUseCase from Riverpod.
    _loginUseCase = ref.read(loginUseCaseProvider);

    // Initial state of the login screen.
    return const LoginState();
  }

  Future<void> login({required String email, required String password}) async {
    // Tell the UI that the login request has started.
    state = const LoginState(isLoading: true);

    try {
      // Delegate the actual login operation
      // to the domain layer.
      final user = await _loginUseCase.execute(
        email: email,
        password: password,
      );

      // Tell the global authentication session
      // that the user is now authenticated.
      ref.read(authSessionNotifierProvider.notifier).authenticated();

      state = LoginState(user: user);
    } catch (error) {
      // Convert the error into a Failure that
      // the presentation layer understands.
      final failure = error is Failure ? error : const UnknownFailure();

      state = LoginState(errorMessage: failure.message);
    }
  }

  /// Clears the current login error.
  ///
  /// Useful when the user starts typing again
  /// after an error.
  void clearError() {
    state = const LoginState();
  }
}

final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
