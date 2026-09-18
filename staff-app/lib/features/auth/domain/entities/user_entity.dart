import 'package:equatable/equatable.dart';

/// Pure Dart Domain Entity representing an authenticated staff member (0 Flutter dependencies).
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    this.permissions = const {},
  });

  final String id;
  final String username;
  final String role;
  final bool isActive;
  final Map<String, dynamic> permissions;

  @override
  List<Object?> get props => [id, username, role, isActive, permissions];
}
