import 'failure.dart';

/// Represents validation errors returned by the API.
///
/// Unlike a normal Failure, this can contain
/// errors for specific fields.
///
/// Example:
///
/// {
///   "firstname": [
///     "Field is required."
///   ],
///   "email": [
///     "Invalid email."
///   ]
/// }
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors = const {}});
}
