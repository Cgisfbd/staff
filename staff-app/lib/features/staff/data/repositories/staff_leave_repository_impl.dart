import 'package:staff_app/features/staff/data/datasources/staff_leave_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/staff_leave_model.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

abstract class StaffLeaveRepository {
  Future<List<StaffLeaveEntity>> getStaffLeaves({
    StaffLeaveStatus? status,
    String? search,
  });

  Future<StaffLeaveStatsEntity> getStaffLeaveStats();

  Future<StaffLeaveEntity> applyStaffLeave({
    required StaffLeaveModel leave,
  });

  Future<StaffLeaveEntity> updateLeaveStatus({
    required String leaveId,
    required StaffLeaveStatus status,
    String? rejectionReason,
  });
}

class StaffLeaveRepositoryImpl implements StaffLeaveRepository {
  StaffLeaveRepositoryImpl({required StaffLeaveRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final StaffLeaveRemoteDataSource _remoteDataSource;

  @override
  Future<List<StaffLeaveEntity>> getStaffLeaves({
    StaffLeaveStatus? status,
    String? search,
  }) async {
    return _remoteDataSource.getStaffLeaves(status: status, search: search);
  }

  @override
  Future<StaffLeaveStatsEntity> getStaffLeaveStats() async {
    return _remoteDataSource.getStaffLeaveStats();
  }

  @override
  Future<StaffLeaveEntity> applyStaffLeave({
    required StaffLeaveModel leave,
  }) async {
    return _remoteDataSource.applyStaffLeave(leave: leave);
  }

  @override
  Future<StaffLeaveEntity> updateLeaveStatus({
    required String leaveId,
    required StaffLeaveStatus status,
    String? rejectionReason,
  }) async {
    return _remoteDataSource.updateLeaveStatus(
      leaveId: leaveId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
