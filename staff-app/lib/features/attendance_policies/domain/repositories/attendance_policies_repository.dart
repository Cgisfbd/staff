import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';

abstract class AttendancePoliciesRepository {
  Future<Either<Failure, AttendancePolicy>> getAttendancePolicies({
    required String academicYearId,
  });

  Future<Either<Failure, AttendancePolicy>> upsertAttendancePolicies({
    required String academicYearId,
    required AttendancePolicy policy,
  });
}
