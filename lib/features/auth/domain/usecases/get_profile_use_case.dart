import '../models/user.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  const GetProfileUseCase(this.repository);

  Future<User> execute() {
    return repository.getProfile();
  }
}
