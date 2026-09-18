import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';

class LockAcademicSessionUseCase {
  const LockAcademicSessionUseCase(this._repository);

  final AcademicSessionRepository _repository;

  Future<Either<Failure, AcademicSessionEntity>> call({
    required String id,
    required String endDate,
    required String pin,
  }) {
    return _repository.lockAcademicSession(
      id: id,
      endDate: endDate,
      pin: pin,
    );
  }
}
