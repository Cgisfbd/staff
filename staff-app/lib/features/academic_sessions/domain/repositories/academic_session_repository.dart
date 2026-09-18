import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';

abstract class AcademicSessionRepository {
  Future<Either<Failure, List<AcademicSessionEntity>>> getAcademicSessions();
  Future<Either<Failure, NextSessionInfoEntity>> getNextSessionInfo();
  Future<Either<Failure, AcademicSessionEntity>> createAcademicSession({
    required String yearName,
    required String startDate,
  });
  Future<Either<Failure, AcademicSessionEntity>> lockAcademicSession({
    required String id,
    required String endDate,
    required String pin,
  });
  Future<Either<Failure, AcademicSessionEntity>> setActiveSession(String id);
}
