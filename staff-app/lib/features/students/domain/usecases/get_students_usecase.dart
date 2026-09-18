import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/domain/repositories/student_directory_repository.dart';

/// Use case to retrieve filtered / paginated students.
class GetStudentsUseCase {
  const GetStudentsUseCase(this._repository);

  final StudentDirectoryRepository _repository;

  Future<List<StudentDirectoryEntity>> call({
    String? search,
    String? status,
    String? courseId,
    String? classId,
    String? modeOfStudy,
    int page = 1,
    int limit = 100,
  }) {
    return _repository.getStudents(
      search: search,
      status: status,
      courseId: courseId,
      classId: classId,
      modeOfStudy: modeOfStudy,
      page: page,
      limit: limit,
    );
  }
}
