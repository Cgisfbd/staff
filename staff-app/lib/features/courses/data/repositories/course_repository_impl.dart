import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  CourseRepositoryImpl({required this.remoteDataSource});

  final CourseRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses() async {
    try {
      final list = await remoteDataSource.getCourses();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure('Failed to load courses: $e'));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> createCourse({
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  }) async {
    try {
      final created = await remoteDataSource.createCourse(
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        description: description,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure('Failed to create course: $e'));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> updateCourse({
    required String id,
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  }) async {
    try {
      final updated = await remoteDataSource.updateCourse(
        id: id,
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        description: description,
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Failed to update course: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse({
    required String id,
    required String pin,
  }) async {
    try {
      await remoteDataSource.deleteCourse(id: id, pin: pin);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete course: $e'));
    }
  }
}
