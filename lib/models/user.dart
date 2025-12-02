import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  const User({
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarUrl: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatarUrl,
    };
  }

  /// Helper to get initials or first letter
  String get initials {
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return '?';
  }

  @override
  List<Object?> get props => [username, email, firstName, lastName, avatarUrl];
}
