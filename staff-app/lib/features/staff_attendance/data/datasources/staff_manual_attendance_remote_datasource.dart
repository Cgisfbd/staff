import 'dart:convert';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/staff/domain/repositories/teacher_directory_repository.dart';
import 'package:staff_app/features/staff_attendance/data/models/staff_manual_attendance_model.dart';
import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';

abstract class StaffManualAttendanceRemoteDataSource {
  Future<List<StaffManualAttendanceModel>> getStaffAttendanceRoster({
    required DateTime date,
  });

  Future<void> saveStaffAttendanceBatch({
    required DateTime date,
    required List<StaffManualAttendanceModel> records,
  });
}

class StaffManualAttendanceRemoteDataSourceImpl
    implements StaffManualAttendanceRemoteDataSource {
  StaffManualAttendanceRemoteDataSourceImpl({
    required this.teacherDirectoryRepository,
    required this.secureStorage,
  });

  final TeacherDirectoryRepository teacherDirectoryRepository;
  final SecureStorageService secureStorage;

  String _dateKey(DateTime date) {
    return 'staff_attendance_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<StaffManualAttendanceModel>> getStaffAttendanceRoster({
    required DateTime date,
  }) async {
    try {
      final key = _dateKey(date);
      final storedJson = await secureStorage.getString(key);

      // 1. If we already have saved manual records for this day, deserialize them
      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(storedJson) as List<dynamic>;
        return list
            .map((item) =>
                StaffManualAttendanceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // 2. Otherwise, load active staff from the directory repository to construct roster
      final teachers = await teacherDirectoryRepository.getTeachers();

      final roster = teachers.map((t) {
        return StaffManualAttendanceModel(
          staffId: t.id,
          staffCode: t.staffCode,
          fullNameEn: t.fullNameEn,
          nameUrdu: t.nameUrdu,
          designation: t.designation,
          department: t.department,
          photoUrl: t.photoUrl,
          status: StaffAttendanceStatus.present,
          punchInTime: null,
          punchOutTime: null,
        );
      }).toList();

      return roster;
    } catch (e) {
      AppLogger.warn('Error fetching staff attendance roster: $e');
      // Fallback empty list or mock
      return [];
    }
  }

  @override
  Future<void> saveStaffAttendanceBatch({
    required DateTime date,
    required List<StaffManualAttendanceModel> records,
  }) async {
    try {
      final key = _dateKey(date);
      final rawList = records.map((r) => r.toJson()).toList();
      final encoded = jsonEncode(rawList);
      await secureStorage.setString(key, encoded);
    } catch (e) {
      AppLogger.error('Failed saving staff attendance batch: $e');
      rethrow;
    }
  }
}
