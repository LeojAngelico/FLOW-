import '../../../../core/models/avatar.dart';
import '../../../../core/models/date_created.dart';

import '../../domain/models/user.dart';

/// Response returned by the login API.
///
/// Example:
///
/// {
///   "msg": "Welcome John Doe !",
///   "status": true,
///   "status_code": "LOGIN_SUCCESS",
///   "token": "...",
///   "token_type": "bearer",
///   "data": { ... }
/// }
class LoginResponseDto {
  final String message;
  final bool status;
  final String statusCode;
  final String token;
  final String tokenType;
  final User user;

  const LoginResponseDto({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return LoginResponseDto(
      message: json['msg'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      statusCode: json['status_code'] as String? ?? '',
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
      user: _parseUser(data),
    );
  }

  /// Converts the API user object into
  /// our shared domain User model.
  static User _parseUser(Map<String, dynamic> data) {
    return User(
      userId: data['user_id'] as int? ?? 0,
      firstName: data['firstname'] as String? ?? '',
      lastName: data['lastname'] as String? ?? '',
      middleName: data['middlename'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      dateCreated: DateCreated.fromJson(
        data['date_created'] as Map<String, dynamic>? ?? {},
      ),
      avatar: Avatar.fromJson(data['avatar'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// The LoginResponseDto itself is a data-layer
  /// object, so this method converts it into
  /// the domain User object used by the app.
  User toDomain() {
    return user;
  }
}

/// Response returned by the refresh-token API.
///
/// Example:
///
/// {
///   "msg": "New access token assigned.",
///   "status": true,
///   "status_code": "ACCESS_TOKEN_UPDATED",
///   "token": "...",
///   "token_type": "Bearer"
/// }
class RefreshTokenResponseDto {
  final String message;
  final bool status;
  final String statusCode;
  final String token;
  final String tokenType;

  const RefreshTokenResponseDto({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.token,
    required this.tokenType,
  });

  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseDto(
      message: json['msg'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      statusCode: json['status_code'] as String? ?? '',
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
    );
  }
}
