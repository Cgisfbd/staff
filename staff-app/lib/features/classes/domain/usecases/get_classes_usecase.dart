import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/domain/repositories/class_repository.dart';

class GetClassesUseCase {
  const GetClassesUseCase(this.repository);

  final ClassRepository repository;

  Future<Either<Failure, List<ClassEntity>>> call({String? courseId}) {
    return repository.getClasses(courseId: courseId);
  }
}
