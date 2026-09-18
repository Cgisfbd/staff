import 'package:equatable/equatable.dart';

/// Pure Dart Domain Entity for Staff Profile (< 40 lines).
class StaffProfileEntity extends Equatable {
  const StaffProfileEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    this.avatarUrl,
    this.hasPin = false,
    this.isTwoFactorEnabled = false,
  });

  final String id;
  final String username;
  final String fullName;
  final String role;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool hasPin;
  final bool isTwoFactorEnabled;

  StaffProfileEntity copyWith({
    String? id,
    String? username,
    String? fullName,
    String? role,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? hasPin,
    bool? isTwoFactorEnabled,
  }) {
    return StaffProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasPin: hasPin ?? this.hasPin,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
    );
  }

  @override
  List<Object?> get props => [id, username, fullName, role, email, phone, avatarUrl, hasPin, isTwoFactorEnabled];
}
