import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/staff/data/models/staff_duty_model.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';

abstract class StaffDutyRemoteDataSource {
  Future<List<StaffDutyModel>> getStaffDuties({
    String? search,
    int page = 1,
    int limit = 100,
  });

  Future<StaffDutyStatsModel> getStaffDutyStats();

  Future<StaffDutyModel> updateStaffDuty({
    required String facultyId,
    required List<String> assignedClasses,
    required List<TeachingBookItem> assignedBooks,
  });
}

class StaffDutyRemoteDataSourceImpl implements StaffDutyRemoteDataSource {
  StaffDutyRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  // In-memory cache list for seamless offline mutation resilience
  static final List<StaffDutyModel> _memoryCache = List.of(StaffDutyModel.seedData);

  @override
  Future<List<StaffDutyModel>> getStaffDuties({
    String? search,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/v1/staff-app/duties',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawList = (data['data'] as List<dynamic>?) ??
            (data['items'] as List<dynamic>?) ??
            (data['duties'] as List<dynamic>?) ??
            [];
        final result = rawList
            .map((item) => StaffDutyModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        if (result.isNotEmpty) {
          // Synchronize memory cache
          for (final item in result) {
            final idx = _memoryCache.indexWhere((c) => c.facultyId == item.facultyId);
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
      AppLogger.warn('Remote duties fetch failed, using offline fallback: $e\n$st');
    }

    // Fallback: in-memory filtered list
    var filtered = List.of(_memoryCache);
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase().trim();
      filtered = filtered.where((d) {
        return d.fullNameEn.toLowerCase().contains(q) ||
            d.fullNameUr.contains(q) ||
            d.staffCode.toString().contains(q) ||
            d.assignedClasses.any((c) => c.toLowerCase().contains(q)) ||
            d.assignedBooks.any((b) => b.bookName.toLowerCase().contains(q));
      }).toList();
    }
    return filtered;
  }

  @override
  Future<StaffDutyStatsModel> getStaffDutyStats() async {
    return StaffDutyStatsModel.fromDuties(_memoryCache);
  }

  @override
  Future<StaffDutyModel> updateStaffDuty({
    required String facultyId,
    required List<String> assignedClasses,
    required List<TeachingBookItem> assignedBooks,
  }) async {
    final bookModels = assignedBooks
        .map((b) => TeachingBookModel(
              courseName: b.courseName,
              className: b.className,
              bookName: b.bookName,
            ))
        .toList();

    try {
      final payload = {
        'attendanceClasses': assignedClasses,
        'teachingAssignments': bookModels.map((b) => b.toJson()).toList(),
      };

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/v1/staff-app/duties/$facultyId',
        data: payload,
      );

      if (response.data is Map<String, dynamic>) {
        final updated = StaffDutyModel.fromJson(response.data as Map<String, dynamic>);
        final idx = _memoryCache.indexWhere((c) => c.facultyId == facultyId);
        if (idx >= 0) {
          _memoryCache[idx] = updated;
        } else {
          _memoryCache.add(updated);
        }
        return updated;
      }
    } catch (e, st) {
      AppLogger.warn('Remote duty update failed, saving to local state: $e\n$st');
    }

    // Fallback: update in memory
    final idx = _memoryCache.indexWhere((c) => c.facultyId == facultyId);
    if (idx >= 0) {
      final old = _memoryCache[idx];
      final updated = old.copyWith(
        assignedClasses: assignedClasses,
        assignedBooks: bookModels,
        isDutyConfigured: assignedClasses.isNotEmpty || bookModels.isNotEmpty,
      );
      final model = StaffDutyModel(
        facultyId: updated.facultyId,
        staffCode: updated.staffCode,
        fullNameEn: updated.fullNameEn,
        fullNameUr: updated.fullNameUr,
        designation: updated.designation,
        department: updated.department,
        phone: updated.phone,
        avatar: updated.avatar,
        isDutyConfigured: updated.isDutyConfigured,
        assignedClasses: updated.assignedClasses,
        assignedBooks: updated.assignedBooks,
        academicYear: updated.academicYear,
      );
      _memoryCache[idx] = model;
      return model;
    }

    throw Exception('Faculty with ID $facultyId not found in roster.');
  }
}
