import 'package:flutter/foundation.dart';

/// Permission levels for granular access control.
enum PermissionLevel {
  none,
  view,
  edit;

  String get key => name;

  static PermissionLevel fromKey(String? key) {
    switch (key?.toLowerCase()) {
      case 'edit':
        return PermissionLevel.edit;
      case 'view':
        return PermissionLevel.view;
      default:
        return PermissionLevel.none;
    }
  }
}

/// Immutable data model representing a Staff Sub-Account user.
@immutable
class StaffSubAccountModel {
  const StaffSubAccountModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.isActive = true,
    this.isTwoFactorEnabled = false,
    this.hasPin = true,
    this.pin = '123456',
    this.temporaryPassword,
    required this.createdAt,
    this.categoryToggles = const {},
    this.permissions = const {},
  });

  factory StaffSubAccountModel.fromJson(Map<String, dynamic> json) {
    return StaffSubAccountModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: (json['role'] as String?)?.toUpperCase() ?? 'STAFF',
      isActive: json['isActive'] as bool? ?? true,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
      hasPin: json['hasPin'] as bool? ?? true,
      pin: json['pin'] as String? ?? '123456',
      temporaryPassword: json['temporaryPassword'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      categoryToggles: (json['categoryToggles'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool),
          ) ??
          const {},
      permissions: (json['permissions'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
    );
  }

  final String id;
  final String name;
  final String username;
  final String email;
  final String role; // 'ADMIN' or 'STAFF'
  final bool isActive;
  final bool isTwoFactorEnabled;
  final bool hasPin;
  final String pin;
  final String? temporaryPassword;
  final DateTime createdAt;

  /// Level 1: Category Master Toggles (Key: categoryId, Value: bool)
  /// If false, the entire main category is hidden from the Menu Left Rail.
  final Map<String, bool> categoryToggles;

  /// Level 2: Granular Sub-Item Permissions (Key: subItemId, Value: 'none' | 'view' | 'edit')
  final Map<String, String> permissions;

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  /// Checks if a main category is allowed to be visible.
  bool isCategoryAllowed(String categoryId, List<String> childSubItemIds) {
    // If master toggle for this category is explicitly false, it is completely hidden
    if (categoryToggles[categoryId] == false) {
      return false;
    }
    // Auto-pruning: If all child sub-items are 'none', hide the category
    if (childSubItemIds.isNotEmpty) {
      final hasAnyVisibleSubItem = childSubItemIds.any((subId) {
        final level = permissions[subId] ?? 'none';
        return level != 'none';
      });
      if (!hasAnyVisibleSubItem) {
        return false;
      }
    }
    return true;
  }

  /// Gets the permission level of a specific sub-item.
  PermissionLevel getSubItemPermission(String subItemId) {
    if (isAdmin) return PermissionLevel.edit;
    final levelStr = permissions[subItemId];
    return PermissionLevel.fromKey(levelStr);
  }

  bool canViewSubItem(String subItemId) {
    if (isAdmin) return true;
    final level = getSubItemPermission(subItemId);
    return level == PermissionLevel.view || level == PermissionLevel.edit;
  }

  bool canEditSubItem(String subItemId) {
    if (isAdmin) return true;
    return getSubItemPermission(subItemId) == PermissionLevel.edit;
  }

  StaffSubAccountModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? role,
    bool? isActive,
    bool? isTwoFactorEnabled,
    bool? hasPin,
    String? pin,
    String? temporaryPassword,
    DateTime? createdAt,
    Map<String, bool>? categoryToggles,
    Map<String, String>? permissions,
  }) {
    return StaffSubAccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      hasPin: hasPin ?? this.hasPin,
      pin: pin ?? this.pin,
      temporaryPassword: temporaryPassword ?? this.temporaryPassword,
      createdAt: createdAt ?? this.createdAt,
      categoryToggles: categoryToggles ?? this.categoryToggles,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'isActive': isActive,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'hasPin': hasPin,
      'pin': pin,
      'temporaryPassword': temporaryPassword,
      'createdAt': createdAt.toIso8601String(),
      'categoryToggles': categoryToggles,
      'permissions': permissions,
    };
  }

  /// Initial realistic mock accounts for testing and offline resilience.
  static List<StaffSubAccountModel> get mockAccounts => [
        StaffSubAccountModel(
          id: 'usr_sub_101',
          name: 'Mawlana Abdur Rahman Qasmi',
          username: 'abdur.rahman',
          email: 'abdur.rahman@taleemone.in',
          role: 'STAFF',
          isActive: true,
          isTwoFactorEnabled: true,
          hasPin: true,
          pin: '849201',
          createdAt: DateTime(2026, 1, 15),
          categoryToggles: const {
            'students': true,
            'attendance': true,
            'exams': true,
            'finance': false,
            'admin_panel': false,
            'sub_accounts': false,
          },
          permissions: const {
            'all_students': 'view',
            'admissions': 'edit',
            'promotions': 'none',
            'student_id_cards': 'none',
            'student_attendance': 'edit',
            'staff_attendance': 'view',
            'monthly_register': 'view',
            'qr_attendance': 'edit',
            'marks_grading': 'edit',
            'question_paper': 'edit',
            'examination_results': 'view',
            'admit_cards': 'none',
            'date_sheets': 'view',
            'financial_overview': 'none',
            'fees_counter': 'none',
            'salary_counter': 'none',
          },
        ),
        StaffSubAccountModel(
          id: 'usr_sub_102',
          name: 'Haji Muhammad Rizwan (Cashier)',
          username: 'rizwan.finance',
          email: 'rizwan.cashier@taleemone.in',
          role: 'STAFF',
          isActive: true,
          isTwoFactorEnabled: false,
          hasPin: true,
          pin: '394821',
          createdAt: DateTime(2026, 2, 1),
          categoryToggles: const {
            'students': true,
            'finance': true,
            'attendance': false,
            'exams': false,
            'admin_panel': false,
            'sub_accounts': false,
          },
          permissions: const {
            'all_students': 'view',
            'admissions': 'none',
            'promotions': 'none',
            'student_id_cards': 'none',
            'financial_overview': 'view',
            'fees_counter': 'edit',
            'salary_counter': 'view',
          },
        ),
        StaffSubAccountModel(
          id: 'usr_sub_103',
          name: 'Mufti Salman Mazahiri (Vice Principal)',
          username: 'salman.admin',
          email: 'salman.vp@taleemone.in',
          role: 'ADMIN',
          isActive: true,
          isTwoFactorEnabled: true,
          hasPin: true,
          pin: '992014',
          createdAt: DateTime(2025, 11, 20),
          categoryToggles: const {
            'students': true,
            'attendance': true,
            'finance': true,
            'staff': true,
            'exams': true,
            'entrance_exam': true,
            'smart_connect': true,
            'sub_accounts': true,
            'admin_panel': true,
          },
          permissions: const {
            'all_students': 'edit',
            'admissions': 'edit',
            'promotions': 'edit',
            'student_id_cards': 'edit',
            'student_attendance': 'edit',
            'staff_attendance': 'edit',
            'monthly_register': 'edit',
            'qr_attendance': 'edit',
            'financial_overview': 'edit',
            'fees_counter': 'edit',
            'salary_counter': 'edit',
            'all_staff': 'edit',
            'add_staff': 'edit',
            'duty_allocation': 'edit',
            'leave_approvals': 'edit',
            'examination_results': 'edit',
            'question_paper': 'edit',
            'marks_grading': 'edit',
          },
        ),
        StaffSubAccountModel(
          id: 'usr_sub_104',
          name: 'Munshi Ahmadullah (Daftar Clerk)',
          username: 'ahmad.clerk',
          email: 'ahmad.clerk@taleemone.in',
          role: 'STAFF',
          isActive: false,
          isTwoFactorEnabled: false,
          hasPin: true,
          pin: '582049',
          createdAt: DateTime(2026, 3, 10),
          categoryToggles: const {
            'students': true,
            'attendance': true,
            'finance': false,
            'exams': false,
          },
          permissions: const {
            'all_students': 'view',
            'admissions': 'edit',
            'promotions': 'view',
            'student_id_cards': 'edit',
            'student_attendance': 'view',
          },
        ),
      ];
}
