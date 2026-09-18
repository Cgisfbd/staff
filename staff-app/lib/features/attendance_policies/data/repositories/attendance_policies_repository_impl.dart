import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/attendance_policies/data/datasources/attendance_policies_remote_datasource.dart';
import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';
import 'package:staff_app/features/attendance_policies/domain/repositories/attendance_policies_repository.dart';

class AttendancePoliciesRepositoryImpl implements AttendancePoliciesRepository {
  AttendancePoliciesRepositoryImpl({required this.remoteDataSource});

  final AttendancePoliciesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, AttendancePolicy>> getAttendancePolicies({
    required String academicYearId,
  }) async {
    try {
      final policy = await remoteDataSource.getAttendancePolicies(
        academicYearId: academicYearId,
      );
      return Right(policy);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendancePolicy>> upsertAttendancePolicies({
    required String academicYearId,
    required AttendancePolicy policy,
  }) async {
    try {
      final saved = await remoteDataSource.upsertAttendancePolicies(
        academicYearId: academicYearId,
        policy: policy,
      );
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
