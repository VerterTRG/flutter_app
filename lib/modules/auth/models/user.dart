import 'package:equatable/equatable.dart';

/// Модель пользователя
class User extends Equatable {
  final int? id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;

  const User({
    this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
  });

  /// Полное имя пользователя
  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    if (parts.isEmpty) return username;
    return parts.join(' ');
  }

  /// Инициалы пользователя для аватара
  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '${firstName![0]}${lastName![0]}'.toUpperCase();
      }
      return firstName![0].toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  /// Создание пользователя из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String?;
    if (username == null || username.isEmpty) {
      throw ArgumentError('Username is required and cannot be empty');
    }
    return User(
      id: json['id'] as int?,
      username: username,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }

  /// Преобразование пользователя в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  /// Создание копии с измененными полями
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  @override
  List<Object?> get props => [id, username, email, firstName, lastName];
}
