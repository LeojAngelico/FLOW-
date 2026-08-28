class RegisterRequestDto {
  final String firstName;
  final String lastName;
  final String middleName;
  final String username;
  final String email;
  final String password;

  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstName,
      'lastname': lastName,
      'middlename': middleName,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
