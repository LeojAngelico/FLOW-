import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<void> execute({
    required String firstName,
    required String lastName,
    required String middleName,
    required String username,
    required String email,
    required String password,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      username: username,
      email: email,
      password: password,
    );
  }
}
