import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/repositories/course_repository.dart';

class CreateCourseUseCase {
  const CreateCourseUseCase(this._repository);

  final CourseRepository _repository;

  Future<Either<Failure, CourseEntity>> call({
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  }) {
    return _repository.createCourse(
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      description: description,
    );
  }
}
