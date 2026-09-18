import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/domain/repositories/class_repository.dart';

class CreateClassUseCase {
  const CreateClassUseCase(this.repository);

  final ClassRepository repository;

  Future<Either<Failure, ClassEntity>> call({
    required String courseId,
    required String nameEnglish,
    String? nameUrdu,
    int? capacity,
  }) {
    return repository.createClass(
      courseId: courseId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      capacity: capacity,
    );
  }
}
