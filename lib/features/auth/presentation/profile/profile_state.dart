import '../../domain/models/user.dart';

class ProfileState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const ProfileState({this.isLoading = false, this.user, this.errorMessage});

  ProfileState copyWith({bool? isLoading, User? user, String? errorMessage}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
