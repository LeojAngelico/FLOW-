import 'error_codes.dart';

/// [message] is either a stable [ErrorCodes] value (resolved to localized
/// text via `ErrorLocalizer` at display time) or, for [ValidationFailure],
/// raw text returned directly by the backend.
abstract class Failure implements Exception {
  final String message;

  const Failure(this.message);
}

/// Used when the device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = ErrorCodes.network]);
}

/// Used when the server returns an unexpected error.
class ServerFailure extends Failure {
  const ServerFailure([super.message = ErrorCodes.server]);
}

/// Used when the user's credentials are invalid.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = ErrorCodes.unauthorized]);
}

/// Used for general authentication-related failures.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Used when the application encounters
/// an unexpected error.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = ErrorCodes.unknown]);
}
