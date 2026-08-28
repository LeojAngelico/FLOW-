class RegistrationState {
  final bool isLoading;
  final bool isSuccess;

  final String? errorMessage;

  // Backend validation errors.
  //
  // Example:
  //
  // {
  //   "firstname": ["Field is required."]
  // }
  final Map<String, List<String>> fieldErrors;

  const RegistrationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });
}
