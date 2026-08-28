/// Failure categories for the Repository -> UseCase -> Notifier
/// boundary. FLOW has no backend, so there are deliberately no
/// network-related cases here.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.field, String message) : super(message);

  final String field;
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
