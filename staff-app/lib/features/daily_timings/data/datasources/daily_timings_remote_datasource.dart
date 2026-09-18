import 'package:dio/dio.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/daily_timings/data/models/schedule_timings_model.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';

abstract class DailyTimingsRemoteDataSource {
  Future<ScheduleTimingsModel> getScheduleTimings({
    required String academicYearId,
  });

  Future<ScheduleTimingsModel> upsertScheduleTimings({
    required String academicYearId,
    required ScheduleTimingsEntity timings,
  });
}

class DailyTimingsRemoteDataSourceImpl implements DailyTimingsRemoteDataSource {
  DailyTimingsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory cache keyed by academicYearId for zero-delay offline fallback
  static final Map<String, ScheduleTimingsModel> _cacheByYear = {};

  @override
  Future<ScheduleTimingsModel> getScheduleTimings({
    required String academicYearId,
  }) async {
    try {
      final response = await apiClient.get<dynamic>(
        '/admin-panel/schedule-timings',
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
          final model = ScheduleTimingsModel.fromJson(raw, fallbackYearId: academicYearId);
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

    final fallback = ScheduleTimingsModel.defaultTimings(academicYearId);
    _cacheByYear[academicYearId] = fallback;
    return fallback;
  }

  @override
  Future<ScheduleTimingsModel> upsertScheduleTimings({
    required String academicYearId,
    required ScheduleTimingsEntity timings,
  }) async {
    final payload = {
      'assemblyTime': timings.assemblyTime,
      'startTime': timings.startTime,
      'lunchAfterPeriod': timings.lunchAfterPeriod,
      'lunchDurationMinutes': timings.lunchDurationMinutes,
      'periodDurations': timings.periodDurations,
    };

    try {
      final response = await apiClient.put<dynamic>(
        '/admin-panel/schedule-timings',
        data: payload,
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
          final saved = ScheduleTimingsModel.fromJson(raw, fallbackYearId: academicYearId);
          _cacheByYear[academicYearId] = saved;
          return saved;
        }
      }
    } catch (_) {
      // Offline fallback handling
    }

    final updatedModel = ScheduleTimingsModel(
      id: timings.id.isNotEmpty ? timings.id : 'local-$academicYearId',
      academicYearId: academicYearId,
      assemblyTime: timings.assemblyTime,
      startTime: timings.startTime,
      lunchAfterPeriod: timings.lunchAfterPeriod,
      lunchDurationMinutes: timings.lunchDurationMinutes,
      lunchStart: timings.lunchStart,
      lunchEnd: timings.lunchEnd,
      endTime: timings.endTime,
      periodDurations: timings.periodDurations,
      updatedAt: DateTime.now(),
    );
    _cacheByYear[academicYearId] = updatedModel;
    return updatedModel;
  }
}
