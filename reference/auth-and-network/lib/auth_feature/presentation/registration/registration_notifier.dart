import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/validation_failure.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/register_use_case.dart';

import 'registration_state.dart';

class RegistrationNotifier extends Notifier<RegistrationState> {
  late final RegisterUseCase _registerUseCase;

  @override
  RegistrationState build() {
    // Get the RegisterUseCase from Riverpod.
    _registerUseCase = ref.read(registerUseCaseProvider);

    // Initial state of the registration screen.
    return const RegistrationState();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String middleName,
    required String username,
    required String email,
    required String password,
  }) async {
    // Tell the UI that registration is currently running.
    state = const RegistrationState(isLoading: true);

    try {
      // Delegate the registration operation
      // to the domain layer.
      await _registerUseCase.execute(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        username: username,
        email: email,
        password: password,
      );

      // Registration succeeded.
      state = const RegistrationState(isSuccess: true);
    } catch (error) {
      // The backend returned field-specific
      // validation errors.
      if (error is ValidationFailure) {
        state = RegistrationState(
          errorMessage: error.message,
          fieldErrors: error.fieldErrors,
        );

        return;
      }

      // Handle other application-level failures.
      final failure = error is Failure ? error : const UnknownFailure();

      state = RegistrationState(errorMessage: failure.message);
    }
  }

  /// Removes the error associated with a field.
  ///
  /// Example:
  /// If "email" currently has an error and
  /// the user starts typing, we can remove
  /// the old email error.
  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field)) {
      return;
    }

    final updatedErrors = Map<String, List<String>>.from(state.fieldErrors);

    updatedErrors.remove(field);

    state = RegistrationState(
      errorMessage: state.errorMessage,
      fieldErrors: updatedErrors,
    );
  }
}

final registrationNotifierProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
      RegistrationNotifier.new,
    );
