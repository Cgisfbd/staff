import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';

class GetAcademicSessionsUseCase {
  const GetAcademicSessionsUseCase(this._repository);

  final AcademicSessionRepository _repository;

  Future<Either<Failure, List<AcademicSessionEntity>>> call() {
    return _repository.getAcademicSessions();
  }
}
