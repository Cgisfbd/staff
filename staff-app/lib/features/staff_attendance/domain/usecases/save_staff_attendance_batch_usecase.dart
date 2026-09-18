import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';
import 'package:staff_app/features/staff_attendance/domain/repositories/staff_attendance_repository.dart';

/// UseCase to batch-save staff manual attendance records (< 25 lines).
class SaveStaffAttendanceBatchUseCase {
  const SaveStaffAttendanceBatchUseCase(this._repository);

  final StaffAttendanceRepository _repository;

  Future<void> call({
    required DateTime date,
    required List<StaffManualAttendanceEntity> records,
  }) {
    return _repository.saveStaffAttendanceBatch(date: date, records: records);
  }
}
