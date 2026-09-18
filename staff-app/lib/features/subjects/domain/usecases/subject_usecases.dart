import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:staff_app/features/subjects/domain/repositories/subject_repository.dart';

class GetSubjectsUseCase {
  const GetSubjectsUseCase(this.repository);
  final SubjectRepository repository;

  Future<List<SubjectEntity>> call({String? courseId, String? classId}) {
    return repository.getSubjects(courseId: courseId, classId: classId);
  }
}

class CreateSubjectUseCase {
  const CreateSubjectUseCase(this.repository);
  final SubjectRepository repository;

  Future<SubjectEntity> call({
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  }) {
    return repository.createSubject(
      classId: classId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
    );
  }
}

class UpdateSubjectUseCase {
  const UpdateSubjectUseCase(this.repository);
  final SubjectRepository repository;

  Future<SubjectEntity> call({
    required String id,
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  }) {
    return repository.updateSubject(
      id: id,
      classId: classId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
    );
  }
}

class DeleteSubjectUseCase {
  const DeleteSubjectUseCase(this.repository);
  final SubjectRepository repository;

  Future<void> call({
    required String id,
    required String pin,
  }) {
    return repository.deleteSubject(id: id, pin: pin);
  }
}
