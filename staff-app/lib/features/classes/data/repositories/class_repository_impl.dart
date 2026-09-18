import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/classes/data/datasources/class_remote_datasource.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements ClassRepository {
  const ClassRepositoryImpl({required this.remoteDataSource});

  final ClassRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<ClassEntity>>> getClasses({String? courseId}) async {
    try {
      final result = await remoteDataSource.getClasses(courseId: courseId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClassEntity>> createClass({
    required String courseId,
    required String nameEnglish,
    String? nameUrdu,
    int? capacity,
  }) async {
    try {
      final result = await remoteDataSource.createClass(
        courseId: courseId,
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        capacity: capacity,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClassEntity>> updateClass({
    required String id,
    String? courseId,
    required String nameEnglish,
    String? nameUrdu,
    int? capacity,
  }) async {
    try {
      final result = await remoteDataSource.updateClass(
        id: id,
        courseId: courseId,
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        capacity: capacity,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClass({
    required String id,
    required String pin,
  }) async {
    try {
      await remoteDataSource.deleteClass(id: id, pin: pin);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
