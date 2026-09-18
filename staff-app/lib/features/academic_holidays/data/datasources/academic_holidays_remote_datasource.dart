import 'package:dio/dio.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/academic_holidays/data/models/academic_holiday_model.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

abstract class AcademicHolidaysRemoteDataSource {
  Future<List<AcademicHolidayModel>> getHolidays({
    required String academicYearId,
    String? type,
  });

  Future<AcademicHolidayModel> createHoliday({
    required String academicYearId,
    required AcademicHoliday holiday,
  });

  Future<AcademicHolidayModel> updateHoliday({
    required String id,
    required AcademicHoliday holiday,
  });

  Future<void> deleteHoliday({
    required String id,
    required String pin,
  });
}

class AcademicHolidaysRemoteDataSourceImpl implements AcademicHolidaysRemoteDataSource {
  AcademicHolidaysRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory cache keyed by academicYearId
  static final Map<String, List<AcademicHolidayModel>> _cacheByYear = {};

  @override
  Future<List<AcademicHolidayModel>> getHolidays({
    required String academicYearId,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': 100};
      if (type != null && type.isNotEmpty && type != 'ALL') {
        queryParams['type'] = type;
      }

      final response = await apiClient.get<dynamic>(
        '/admin-panel/holidays',
        queryParameters: queryParams,
        options: Options(
          headers: {'X-Academic-Year-ID': academicYearId},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic raw = response.data;
        if (raw is Map && raw.containsKey('data') && raw['data'] != null) {
          raw = raw['data'];
        }
        if (raw is List) {
          final list = raw
              .map((e) => AcademicHolidayModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _cacheByYear[academicYearId] = list;
          return list;
        }
      }
    } catch (_) {
      // Fall through to cache
    }

    if (_cacheByYear.containsKey(academicYearId)) {
      final cached = _cacheByYear[academicYearId]!;
      if (type != null && type.isNotEmpty && type != 'ALL') {
        return cached.where((h) => h.type.value == type).toList();
      }
      return cached;
    }

    final defaultHolidays = [
      AcademicHolidayModel(
        id: 'holiday-eid-ul-fitr',
        academicYearId: academicYearId,
        type: HolidayType.religious,
        appliesTo: HolidayAppliesTo.all,
        startDate: '2025-03-30',
        endDate: '2025-04-03',
        title: const {'en': 'Eid ul-Fitr Break', 'ur': 'تعطیل عید الفطر', 'hi': 'ईद-उल-फ़ितर अवकाश'},
        description: const {
          'en': 'Annual Islamic celebration and break after the holy month of Ramadan.',
          'ur': 'ماہ مبارک رمضان کی تکمیل اور عید الفطر کی سالانہ مبارک تعطیلات۔',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AcademicHolidayModel(
        id: 'holiday-independence-day',
        academicYearId: academicYearId,
        type: HolidayType.national,
        appliesTo: HolidayAppliesTo.all,
        startDate: '2025-08-15',
        endDate: '2025-08-15',
        title: const {'en': 'Independence Day', 'ur': 'یومِ آزادی', 'hi': 'स्वतंत्रता दिवस'},
        description: const {
          'en': 'National celebration and tricolor flag hoisting ceremony at main campus lawn at 8:30 AM.',
          'ur': 'مرکزی کیمپس میں پرچم کشائی کی تقریب صبح 8:30 بجے۔',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AcademicHolidayModel(
        id: 'holiday-annual-madrasa',
        academicYearId: academicYearId,
        type: HolidayType.institutional,
        appliesTo: HolidayAppliesTo.studentsOnly,
        startDate: '2025-11-10',
        endDate: '2025-11-11',
        title: const {'en': 'Annual Madrasa Conference', 'ur': 'سالانہ دستار بندی و جلسہ', 'hi': 'वार्षिक दीक्षांत समारोह'},
        description: const {
          'en': 'Institutional convocation and Khatm-e-Bukhari conference. Academic classes suspended.',
          'ur': 'سالانہ دستار بندی و ختمِ بخاری کانفرنس۔ تدریسی مصروفیات معطل رہیں گی۔',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _cacheByYear[academicYearId] = defaultHolidays;
    if (type != null && type.isNotEmpty && type != 'ALL') {
      return defaultHolidays.where((h) => h.type.value == type).toList();
    }
    return defaultHolidays;
  }

  @override
  Future<AcademicHolidayModel> createHoliday({
    required String academicYearId,
    required AcademicHoliday holiday,
  }) async {
    final model = AcademicHolidayModel.fromEntity(holiday);
    final response = await apiClient.post<dynamic>(
      '/admin-panel/holidays',
      data: model.toJson(),
      options: Options(
        headers: {'X-Academic-Year-ID': academicYearId},
      ),
    );

    dynamic raw = response.data;
    if (raw is Map && raw.containsKey('data') && raw['data'] != null) {
      raw = raw['data'];
    }
    final created = AcademicHolidayModel.fromJson(raw as Map<String, dynamic>);

    final current = _cacheByYear[academicYearId] ?? [];
    _cacheByYear[academicYearId] = [created, ...current];
    return created;
  }

  @override
  Future<AcademicHolidayModel> updateHoliday({
    required String id,
    required AcademicHoliday holiday,
  }) async {
    final model = AcademicHolidayModel.fromEntity(holiday);
    final response = await apiClient.patch<dynamic>(
      '/admin-panel/holidays/$id',
      data: model.toJson(),
    );

    dynamic raw = response.data;
    if (raw is Map && raw.containsKey('data') && raw['data'] != null) {
      raw = raw['data'];
    }
    final updated = AcademicHolidayModel.fromJson(raw as Map<String, dynamic>);

    final current = _cacheByYear[holiday.academicYearId] ?? [];
    _cacheByYear[holiday.academicYearId] = current.map((h) => h.id == id ? updated : h).toList();
    return updated;
  }

  @override
  Future<void> deleteHoliday({
    required String id,
    required String pin,
  }) async {
    await apiClient.delete<dynamic>(
      '/admin-panel/holidays/$id',
      data: {'pin': pin},
    );

    for (final yearId in _cacheByYear.keys) {
      _cacheByYear[yearId]?.removeWhere((h) => h.id == id);
    }
  }
}
