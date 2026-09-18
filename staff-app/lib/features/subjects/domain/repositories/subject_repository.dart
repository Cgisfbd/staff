import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

abstract class SubjectRepository {
  Future<List<SubjectEntity>> getSubjects({String? courseId, String? classId});
  Future<SubjectEntity> createSubject({
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  });
  Future<SubjectEntity> updateSubject({
    required String id,
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  });
  Future<void> deleteSubject({
    required String id,
    required String pin,
  });
}
