import 'package:staff_app/features/subjects/data/datasources/subject_remote_datasource.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:staff_app/features/subjects/domain/repositories/subject_repository.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  SubjectRepositoryImpl({required this.remoteDataSource});

  final SubjectRemoteDataSource remoteDataSource;

  @override
  Future<List<SubjectEntity>> getSubjects({String? courseId, String? classId}) {
    return remoteDataSource.getSubjects(courseId: courseId, classId: classId);
  }

  @override
  Future<SubjectEntity> createSubject({
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  }) {
    return remoteDataSource.createSubject(
      classId: classId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
    );
  }

  @override
  Future<SubjectEntity> updateSubject({
    required String id,
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  }) {
    return remoteDataSource.updateSubject(
      id: id,
      classId: classId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
    );
  }

  @override
  Future<void> deleteSubject({
    required String id,
    required String pin,
  }) {
    return remoteDataSource.deleteSubject(id: id, pin: pin);
  }
}
