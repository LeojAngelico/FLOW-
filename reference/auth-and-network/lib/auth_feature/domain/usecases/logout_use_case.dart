import 'package:flutter/cupertino.dart';

import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<void> execute() async {
    debugPrint('🟣 USECASE: LogoutUseCase.execute() called.');

    await repository.logout();

    debugPrint('🟢 USECASE: repository.logout() completed.');
  }
}
