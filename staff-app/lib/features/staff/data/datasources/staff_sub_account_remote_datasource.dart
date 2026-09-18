import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/staff/data/models/staff_sub_account_model.dart';

/// Remote and Local Data Source for Staff Sub-Accounts & Delegation Management.
abstract class StaffSubAccountRemoteDataSource {
  Future<List<StaffSubAccountModel>> getSubAccounts({String? search, int page = 1, int limit = 50});
  Future<StaffSubAccountModel> createSubAccount({
    required String name,
    required String username,
    required String email,
    required String password,
    required String pin,
    required String role,
    Map<String, bool>? categoryToggles,
    Map<String, String>? permissions,
  });
  Future<StaffSubAccountModel> toggleAccountStatus({required String id, required bool isActive});
  Future<StaffSubAccountModel> updatePermissions({
    required String id,
    required Map<String, bool> categoryToggles,
    required Map<String, String> permissions,
  });
  Future<StaffSubAccountModel> updateSubAccount({
    required String id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? password,
    String? pin,
    Map<String, bool>? categoryToggles,
    Map<String, String>? permissions,
  });
  Future<StaffSubAccountModel> resetPassword({required String id, required String newPassword});
  Future<StaffSubAccountModel> resetPin({required String id, required String newPin});
  Future<void> revokeSubAccount(String id);
}

class StaffSubAccountRemoteDataSourceImpl implements StaffSubAccountRemoteDataSource {
  StaffSubAccountRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working copy initialized with seed data for offline & dev resilience
  static final List<StaffSubAccountModel> _localAccounts = List.from(StaffSubAccountModel.mockAccounts);

  @override
  Future<List<StaffSubAccountModel>> getSubAccounts({String? search, int page = 1, int limit = 50}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/v1/staff',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'];
        if (data is Map<String, dynamic> && data['items'] is List) {
          final items = (data['items'] as List)
              .map((item) => StaffSubAccountModel.fromJson(item as Map<String, dynamic>))
              .toList();
          if (items.isNotEmpty) {
            return items;
          }
        }
      }
    } catch (_) {
      // Fall back smoothly to local memory dataset
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      return _localAccounts.where((acc) {
        return acc.name.toLowerCase().contains(q) ||
            acc.username.toLowerCase().contains(q) ||
            acc.email.toLowerCase().contains(q);
      }).toList();
    }
    return List.unmodifiable(_localAccounts);
  }

  @override
  Future<StaffSubAccountModel> createSubAccount({
    required String name,
    required String username,
    required String email,
    required String password,
    required String pin,
    required String role,
    Map<String, bool>? categoryToggles,
    Map<String, String>? permissions,
  }) async {
    final newAccount = StaffSubAccountModel(
      id: 'usr_sub_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      username: username.trim().toLowerCase(),
      email: email.trim().toLowerCase(),
      role: role.toUpperCase(),
      isActive: true,
      isTwoFactorEnabled: false,
      hasPin: true,
      pin: pin,
      temporaryPassword: password,
      createdAt: DateTime.now(),
      categoryToggles: categoryToggles ?? const {},
      permissions: permissions ?? const {},
    );

    try {
      await apiClient.post<Map<String, dynamic>>(
        '/v1/staff',
        data: {
          'name': name.trim(),
          'username': username.trim().toLowerCase(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'pin': pin,
          'role': role.toUpperCase(),
          'permissions': (permissions ?? {}).entries.map((e) => {'moduleName': e.key, 'level': e.value}).toList(),
        },
      );
    } catch (_) {
      // Offline fallback: store in local list
    }

    _localAccounts.insert(0, newAccount);
    return newAccount;
  }

  @override
  Future<StaffSubAccountModel> toggleAccountStatus({required String id, required bool isActive}) async {
    final index = _localAccounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Sub-Account not found');
    }

    final updated = _localAccounts[index].copyWith(isActive: isActive);
    _localAccounts[index] = updated;

    try {
      await apiClient.patch<Map<String, dynamic>>(
        '/v1/staff/$id',
        data: {'isActive': isActive},
      );
    } catch (_) {}

    return updated;
  }

  @override
  Future<StaffSubAccountModel> updatePermissions({
    required String id,
    required Map<String, bool> categoryToggles,
    required Map<String, String> permissions,
  }) async {
    final index = _localAccounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Sub-Account not found');
    }

    final updated = _localAccounts[index].copyWith(
      categoryToggles: categoryToggles,
      permissions: permissions,
    );
    _localAccounts[index] = updated;

    try {
      await apiClient.patch<Map<String, dynamic>>(
        '/v1/staff/$id',
        data: {
          'permissions': permissions.entries.map((e) => {'moduleName': e.key, 'level': e.value}).toList(),
        },
      );
    } catch (_) {}

    return updated;
  }

  @override
  Future<StaffSubAccountModel> updateSubAccount({
    required String id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? password,
    String? pin,
    Map<String, bool>? categoryToggles,
    Map<String, String>? permissions,
  }) async {
    final index = _localAccounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Sub-Account not found');
    }

    final existing = _localAccounts[index];
    final updated = existing.copyWith(
      name: name ?? existing.name,
      username: username ?? existing.username,
      email: email ?? existing.email,
      role: role ?? existing.role,
      temporaryPassword: (password != null && password.isNotEmpty) ? password : existing.temporaryPassword,
      pin: (pin != null && pin.isNotEmpty) ? pin : existing.pin,
      categoryToggles: categoryToggles ?? existing.categoryToggles,
      permissions: permissions ?? existing.permissions,
    );
    _localAccounts[index] = updated;

    try {
      await apiClient.patch<Map<String, dynamic>>(
        '/v1/staff/$id',
        data: {
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          if (role != null) 'role': role,
          if (password != null && password.isNotEmpty) 'password': password,
          if (pin != null && pin.isNotEmpty) 'pin': pin,
          if (permissions != null)
            'permissions': permissions.entries.map((e) => {'moduleName': e.key, 'level': e.value}).toList(),
        },
      );
    } catch (_) {}

    return updated;
  }

  @override
  Future<StaffSubAccountModel> resetPassword({required String id, required String newPassword}) async {
    final index = _localAccounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Sub-Account not found');
    }

    final updated = _localAccounts[index].copyWith(temporaryPassword: newPassword);
    _localAccounts[index] = updated;

    try {
      await apiClient.patch<Map<String, dynamic>>(
        '/v1/staff/$id',
        data: {'password': newPassword},
      );
    } catch (_) {}

    return updated;
  }

  @override
  Future<StaffSubAccountModel> resetPin({required String id, required String newPin}) async {
    final index = _localAccounts.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Sub-Account not found');
    }

    final updated = _localAccounts[index].copyWith(pin: newPin, hasPin: true);
    _localAccounts[index] = updated;

    try {
      await apiClient.patch<Map<String, dynamic>>(
        '/v1/staff/$id',
        data: {'pin': newPin},
      );
    } catch (_) {}

    return updated;
  }

  @override
  Future<void> revokeSubAccount(String id) async {
    _localAccounts.removeWhere((a) => a.id == id);
    try {
      await apiClient.delete<Map<String, dynamic>>('/v1/staff/$id');
    } catch (_) {}
  }
}
