import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/repositories/course_repository.dart';

class UpdateCourseUseCase {
  const UpdateCourseUseCase(this._repository);

  final CourseRepository _repository;

  Future<Either<Failure, CourseEntity>> call({
    required String id,
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  }) {
    return _repository.updateCourse(
      id: id,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      description: description,
    );
  }
}
