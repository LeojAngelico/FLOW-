enum AuthSessionStatus { checking, authenticated, unauthenticated }

class AuthSessionState {
  final AuthSessionStatus status;
  final String? message;

  const AuthSessionState({required this.status, this.message});

  const AuthSessionState.checking()
    : status = AuthSessionStatus.checking,
      message = null;

  const AuthSessionState.authenticated()
    : status = AuthSessionStatus.authenticated,
      message = null;

  const AuthSessionState.unauthenticated({String? message})
    : status = AuthSessionStatus.unauthenticated,
      message = message;
}
