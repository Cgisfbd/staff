import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/courses/domain/repositories/course_repository.dart';

class DeleteCourseUseCase {
  const DeleteCourseUseCase(this._repository);

  final CourseRepository _repository;

  Future<Either<Failure, void>> call({
    required String id,
    required String pin,
  }) {
    return _repository.deleteCourse(id: id, pin: pin);
  }
}
