import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/storage/storage_providers.dart';

import '../../domain/providers/auth_domain_providers.dart';

import 'auth_session_state.dart';

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() {
    final sessionManager = ref.read(authSessionManagerProvider);

    // The network layer uses this callback when
    // the authentication session can no longer
    // be recovered.
    sessionManager.setOnSessionExpired(() async {
      await _handleSessionExpired();
    });

    return const AuthSessionState.checking();
  }

  /// Initializes the authentication session.
  ///
  /// Called by the Splash Screen when the
  /// application starts.
  Future<void> initializeSession() async {
    state = const AuthSessionState.checking();

    final storage = ref.read(secureStorageProvider);

    final token = await storage.getAccessToken();

    // No stored token.
    if (token == null || token.isEmpty) {
      state = const AuthSessionState.unauthenticated();

      return;
    }

    try {
      final refreshTokenUseCase = ref.read(refreshTokenUseCaseProvider);

      // Attempt to refresh the existing
      // access token.
      await refreshTokenUseCase.execute();

      state = const AuthSessionState.authenticated();
    } catch (error) {
      // Refresh failed.
      //
      // Clear the invalid session and force
      // the user to login again.
      await storage.clearTokens();

      state = const AuthSessionState.unauthenticated(
        message: 'Your session has expired. Please login again.',
      );
    }
  }

  /// Marks the current session as authenticated.
  ///
  /// Called after a successful login.
  void authenticated() {
    state = const AuthSessionState.authenticated();
  }

  /// Logs the user out.
  ///
  /// Regardless of whether the logout API
  /// succeeds or fails, the local session
  /// is terminated.
  Future<void> logout() async {
    final logoutUseCase = ref.read(logoutUseCaseProvider);

    try {
      await logoutUseCase.execute();

      state = const AuthSessionState.unauthenticated(
        message: 'Successfully logged out.',
      );
    } catch (error) {
      // Even if the API logout fails, we still
      // terminate the local session.
      state = const AuthSessionState.unauthenticated(
        message: 'Logout completed locally. Please login again.',
      );
    }
  }

  /// Called by the network layer when the
  /// authentication session can no longer
  /// be recovered.
  Future<void> _handleSessionExpired() async {
    final storage = ref.read(secureStorageProvider);

    await storage.clearTokens();

    state = const AuthSessionState.unauthenticated(
      message: 'Your session has expired. Please login again.',
    );
  }
}

final authSessionNotifierProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
