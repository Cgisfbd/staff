import 'package:staff_app/features/auth/domain/entities/user_entity.dart';

/// Data Transfer Model for User mapping API response JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    required super.isActive,
    super.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['permissions'];
    final Map<String, dynamic> permissionsMap = {};

    if (rawPerms is Map) {
      permissionsMap.addAll(Map<String, dynamic>.from(rawPerms));
    } else if (rawPerms is List) {
      for (final item in rawPerms) {
        if (item is Map && item.containsKey('module')) {
          permissionsMap[item['module'].toString()] = item['level']?.toString() ?? 'view';
        }
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'STAFF',
      isActive: json['isActive'] == true || json['is_active'] == true,
      permissions: permissionsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'isActive': isActive,
      'permissions': permissions,
    };
  }
}
