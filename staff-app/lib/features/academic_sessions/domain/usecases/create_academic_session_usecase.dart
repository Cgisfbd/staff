import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';

class CreateAcademicSessionUseCase {
  const CreateAcademicSessionUseCase(this._repository);

  final AcademicSessionRepository _repository;

  Future<Either<Failure, AcademicSessionEntity>> call({
    required String yearName,
    required String startDate,
  }) {
    return _repository.createAcademicSession(
      yearName: yearName,
      startDate: startDate,
    );
  }
}
