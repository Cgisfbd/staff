import 'package:staff_app/features/staff/data/datasources/staff_duty_remote_datasource.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';
import 'package:staff_app/features/staff/domain/repositories/staff_duty_repository.dart';

class StaffDutyRepositoryImpl implements StaffDutyRepository {
  const StaffDutyRepositoryImpl({required StaffDutyRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final StaffDutyRemoteDataSource _remoteDataSource;

  @override
  Future<List<StaffDutyEntity>> getStaffDuties({String? search}) async {
    return _remoteDataSource.getStaffDuties(search: search);
  }

  @override
  Future<StaffDutyStatsEntity> getStaffDutyStats() async {
    return _remoteDataSource.getStaffDutyStats();
  }

  @override
  Future<StaffDutyEntity> updateStaffDuty({
    required String facultyId,
    required List<String> assignedClasses,
    required List<TeachingBookItem> assignedBooks,
  }) async {
    return _remoteDataSource.updateStaffDuty(
      facultyId: facultyId,
      assignedClasses: assignedClasses,
      assignedBooks: assignedBooks,
    );
  }
}
