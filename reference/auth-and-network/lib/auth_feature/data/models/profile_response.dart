import '../../../../core/models/avatar.dart';
import '../../../../core/models/date_created.dart';

import '../../domain/models/user.dart';

class ProfileResponseDto {
  final String message;
  final bool status;
  final String statusCode;
  final User user;

  const ProfileResponseDto({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.user,
  });

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return ProfileResponseDto(
      message: json['msg'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      statusCode: json['status_code'] as String? ?? '',
      user: User(
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
      ),
    );
  }
}
