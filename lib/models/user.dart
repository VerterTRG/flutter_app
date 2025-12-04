import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id; // id может быть 0
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl; // maps to 'logo' from API
  final String? companyName; // flattened from company.name
  final bool isStaff;
  final bool isActive;

  const User({
    this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.companyName,
    this.isStaff = false,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      avatarUrl: json['logo'], // API uses 'logo'
      companyName: json['company'] != null ? json['company']['name'] : null,
      isStaff: json['is_staff'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'logo': avatarUrl,
      'company': companyName != null ? {'name': companyName} : null,
      'is_staff': isStaff,
      'is_active': isActive,
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
  List<Object?> get props => [id, username, email, firstName, lastName, phone, avatarUrl, companyName, isStaff, isActive];
}
