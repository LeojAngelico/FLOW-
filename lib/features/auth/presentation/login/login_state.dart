import '../../domain/models/user.dart';

class LoginState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const LoginState({this.isLoading = false, this.user, this.errorMessage});
}
