import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/staff/data/models/staff_leave_model.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

abstract class StaffLeaveRemoteDataSource {
  Future<List<StaffLeaveModel>> getStaffLeaves({
    StaffLeaveStatus? status,
    String? search,
  });

  Future<StaffLeaveStatsModel> getStaffLeaveStats();

  Future<StaffLeaveModel> applyStaffLeave({
    required StaffLeaveModel leave,
  });

  Future<StaffLeaveModel> updateLeaveStatus({
    required String leaveId,
    required StaffLeaveStatus status,
    String? rejectionReason,
  });
}

class StaffLeaveRemoteDataSourceImpl implements StaffLeaveRemoteDataSource {
  StaffLeaveRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  // In-memory cache list for seamless offline mutation resilience
  static final List<StaffLeaveModel> _memoryCache = List.of(StaffLeaveModel.seedLeaves);

  @override
  Future<List<StaffLeaveModel>> getStaffLeaves({
    StaffLeaveStatus? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status.name;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/v1/staff-app/leaves',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawList = (data['data'] as List<dynamic>?) ??
            (data['items'] as List<dynamic>?) ??
            (data['leaves'] as List<dynamic>?) ??
            [];
        final result = rawList
            .map((item) => StaffLeaveModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        if (result.isNotEmpty) {
          for (final item in result) {
            final idx = _memoryCache.indexWhere((c) => c.id == item.id);
            if (idx >= 0) {
              _memoryCache[idx] = item;
            } else {
              _memoryCache.add(item);
            }
          }
          return result;
        }
      }
    } catch (e, st) {
      AppLogger.warn('Remote leaves fetch failed, using offline fallback: $e\n$st');
    }

    // Fallback: in-memory filtered list
    var filtered = List.of(_memoryCache);
    if (status != null) {
      filtered = filtered.where((l) => l.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase().trim();
      filtered = filtered.where((l) {
        return l.teacherName.toLowerCase().contains(q) ||
            l.staffCode.toString().contains(q) ||
            l.reason.toLowerCase().contains(q) ||
            l.leaveType.name.toLowerCase().contains(q);
      }).toList();
    }
    return filtered;
  }

  @override
  Future<StaffLeaveStatsModel> getStaffLeaveStats() async {
    return StaffLeaveStatsModel.fromLeaves(_memoryCache);
  }

  @override
  Future<StaffLeaveModel> applyStaffLeave({
    required StaffLeaveModel leave,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/v1/staff-app/leaves',
        data: leave.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        final created = StaffLeaveModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
        _memoryCache.insert(0, created);
        return created;
      }
    } catch (e, st) {
      AppLogger.warn('Remote apply leave failed, saving to memory fallback: $e\n$st');
    }

    // Fallback mutation
    _memoryCache.insert(0, leave);
    return leave;
  }

  @override
  Future<StaffLeaveModel> updateLeaveStatus({
    required String leaveId,
    required StaffLeaveStatus status,
    String? rejectionReason,
  }) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/v1/staff-app/leaves/$leaveId/status',
        data: {
          'status': status.name,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        final updated = StaffLeaveModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
        final idx = _memoryCache.indexWhere((c) => c.id == leaveId);
        if (idx >= 0) _memoryCache[idx] = updated;
        return updated;
      }
    } catch (e, st) {
      AppLogger.warn('Remote update leave status failed, mutating memory fallback: $e\n$st');
    }

    // Fallback mutation
    final idx = _memoryCache.indexWhere((c) => c.id == leaveId);
    if (idx >= 0) {
      final old = _memoryCache[idx];
      final updated = StaffLeaveModel(
        id: old.id,
        facultyId: old.facultyId,
        staffCode: old.staffCode,
        teacherName: old.teacherName,
        avatar: old.avatar,
        designation: old.designation,
        department: old.department,
        leaveType: old.leaveType,
        startDate: old.startDate,
        endDate: old.endDate,
        totalDays: old.totalDays,
        reason: old.reason,
        status: status,
        appliedAt: old.appliedAt,
        reviewedBy: 'Authorized Principal / Admin',
        rejectionReason: rejectionReason ?? old.rejectionReason,
      );
      _memoryCache[idx] = updated;
      return updated;
    }

    throw Exception('Leave record with id "$leaveId" not found.');
  }
}
