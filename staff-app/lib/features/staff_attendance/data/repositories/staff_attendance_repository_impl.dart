import 'package:staff_app/features/staff_attendance/data/datasources/staff_manual_attendance_remote_datasource.dart';
import 'package:staff_app/features/staff_attendance/data/models/staff_manual_attendance_model.dart';
import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';
import 'package:staff_app/features/staff_attendance/domain/repositories/staff_attendance_repository.dart';

/// Implementation of StaffAttendanceRepository (< 40 lines).
class StaffAttendanceRepositoryImpl implements StaffAttendanceRepository {
  const StaffAttendanceRepositoryImpl({required this.remoteDataSource});

  final StaffManualAttendanceRemoteDataSource remoteDataSource;

  @override
  Future<List<StaffManualAttendanceEntity>> getStaffAttendanceRoster({
    required DateTime date,
  }) {
    return remoteDataSource.getStaffAttendanceRoster(date: date);
  }

  @override
  Future<void> saveStaffAttendanceBatch({
    required DateTime date,
    required List<StaffManualAttendanceEntity> records,
  }) {
    final models = records
        .map((e) => StaffManualAttendanceModel.fromEntity(e))
        .toList();
    return remoteDataSource.saveStaffAttendanceBatch(
      date: date,
      records: models,
    );
  }
}
