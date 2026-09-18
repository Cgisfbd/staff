import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  const GetCoursesUseCase(this._repository);

  final CourseRepository _repository;

  Future<Either<Failure, List<CourseEntity>>> call() {
    return _repository.getCourses();
  }
}
