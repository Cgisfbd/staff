import 'package:dio/dio.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/attendance_policies/data/models/attendance_policy_model.dart';
import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';

abstract class AttendancePoliciesRemoteDataSource {
  Future<AttendancePolicyModel> getAttendancePolicies({
    required String academicYearId,
  });

  Future<AttendancePolicyModel> upsertAttendancePolicies({
    required String academicYearId,
    required AttendancePolicy policy,
  });
}

class AttendancePoliciesRemoteDataSourceImpl implements AttendancePoliciesRemoteDataSource {
  AttendancePoliciesRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  static final Map<String, AttendancePolicyModel> _cacheByYear = {};

  @override
  Future<AttendancePolicyModel> getAttendancePolicies({
    required String academicYearId,
  }) async {
    try {
      final response = await apiClient.get<dynamic>(
        '/admin-panel/attendance-policies',
        options: Options(
          headers: {'X-Academic-Year-ID': academicYearId},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;
        if (raw is Map && raw.containsKey('data') && raw['data'] != null) {
          raw = raw['data'];
        }
        if (raw is Map<String, dynamic>) {
          final model = AttendancePolicyModel.fromJson(raw, fallbackYearId: academicYearId);
          _cacheByYear[academicYearId] = model;
          return model;
        }
      }
    } catch (_) {
      // Fall through to cache
    }

    if (_cacheByYear.containsKey(academicYearId)) {
      return _cacheByYear[academicYearId]!;
    }

    final fallback = AttendancePolicyModel(
      id: 'default-$academicYearId',
      academicYearId: academicYearId,
      minimumAttendancePercent: 75,
      annualStudentLeaveQuota: 14,
      annualStaffLeaveQuota: 14,
      consecutiveAbsentDropoutDays: 15,
      weeklyOffDay: 'FRIDAY',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _cacheByYear[academicYearId] = fallback;
    return fallback;
  }

  @override
  Future<AttendancePolicyModel> upsertAttendancePolicies({
    required String academicYearId,
    required AttendancePolicy policy,
  }) async {
    final model = AttendancePolicyModel.fromEntity(policy);
    try {
      final response = await apiClient.put<dynamic>(
        '/admin-panel/attendance-policies',
        data: model.toJson(),
        options: Options(
          headers: {'X-Academic-Year-ID': academicYearId},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;
        if (raw is Map && raw.containsKey('data') && raw['data'] != null) {
          raw = raw['data'];
        }
        if (raw is Map<String, dynamic>) {
          final saved = AttendancePolicyModel.fromJson(raw, fallbackYearId: academicYearId);
          _cacheByYear[academicYearId] = saved;
          return saved;
        }
      }
    } catch (_) {
      // Offline fallback
    }

    _cacheByYear[academicYearId] = model;
    return model;
  }
}
