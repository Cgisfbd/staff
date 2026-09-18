import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';

/// Contract definition for Staff Manual Attendance operations (< 30 lines).
abstract class StaffAttendanceRepository {
  Future<List<StaffManualAttendanceEntity>> getStaffAttendanceRoster({
    required DateTime date,
  });

  Future<void> saveStaffAttendanceBatch({
    required DateTime date,
    required List<StaffManualAttendanceEntity> records,
  });
}
