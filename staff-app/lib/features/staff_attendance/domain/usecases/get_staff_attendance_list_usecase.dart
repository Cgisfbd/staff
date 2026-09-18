import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';
import 'package:staff_app/features/staff_attendance/domain/repositories/staff_attendance_repository.dart';

/// UseCase to retrieve staff manual attendance roster for a given date (< 25 lines).
class GetStaffAttendanceListUseCase {
  const GetStaffAttendanceListUseCase(this._repository);

  final StaffAttendanceRepository _repository;

  Future<List<StaffManualAttendanceEntity>> call({required DateTime date}) {
    return _repository.getStaffAttendanceRoster(date: date);
  }
}
