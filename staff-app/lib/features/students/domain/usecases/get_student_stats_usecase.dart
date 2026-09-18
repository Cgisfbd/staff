import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/domain/repositories/student_directory_repository.dart';

/// Use case to retrieve KPI statistics for students.
class GetStudentStatsUseCase {
  const GetStudentStatsUseCase(this._repository);

  final StudentDirectoryRepository _repository;

  Future<StudentStatsEntity> call() {
    return _repository.getStudentStats();
  }
}
