import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';

abstract class ClassRepository {
  Future<Either<Failure, List<ClassEntity>>> getClasses({String? courseId});
  Future<Either<Failure, ClassEntity>> createClass({
    required String courseId,
    required String nameEnglish,
    String? nameUrdu,
    int? capacity,
  });
  Future<Either<Failure, ClassEntity>> updateClass({
    required String id,
    String? courseId,
    required String nameEnglish,
    String? nameUrdu,
    int? capacity,
  });
  Future<Either<Failure, void>> deleteClass({
    required String id,
    required String pin,
  });
}
