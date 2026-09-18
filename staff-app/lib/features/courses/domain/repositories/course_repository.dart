import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses();
  Future<Either<Failure, CourseEntity>> createCourse({
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  });
  Future<Either<Failure, CourseEntity>> updateCourse({
    required String id,
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  });
  Future<Either<Failure, void>> deleteCourse({
    required String id,
    required String pin,
  });
}
