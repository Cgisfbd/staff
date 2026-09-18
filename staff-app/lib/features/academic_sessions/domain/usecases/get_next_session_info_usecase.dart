import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';

class GetNextSessionInfoUseCase {
  const GetNextSessionInfoUseCase(this._repository);

  final AcademicSessionRepository _repository;

  Future<Either<Failure, NextSessionInfoEntity>> call() {
    return _repository.getNextSessionInfo();
  }
}
