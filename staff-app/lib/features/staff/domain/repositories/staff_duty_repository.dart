import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';

abstract class StaffDutyRepository {
  Future<List<StaffDutyEntity>> getStaffDuties({String? search});

  Future<StaffDutyStatsEntity> getStaffDutyStats();

  Future<StaffDutyEntity> updateStaffDuty({
    required String facultyId,
    required List<String> assignedClasses,
    required List<TeachingBookItem> assignedBooks,
  });
}
