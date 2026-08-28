import '../../../../core/models/avatar.dart';
import '../../../../core/models/date_created.dart';

class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String name;
  final String email;
  final String username;
  final DateCreated dateCreated;
  final Avatar avatar;

  const User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.name,
    required this.email,
    required this.username,
    required this.dateCreated,
    required this.avatar,
  });
}
