import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';

/// Pure Dart contract defining Student Directory operations.
abstract class StudentDirectoryRepository {
  Future<List<StudentDirectoryEntity>> getStudents({
    String? search,
    String? status,
    String? courseId,
    String? classId,
    String? modeOfStudy,
    int page = 1,
    int limit = 100,
  });

  Future<StudentStatsEntity> getStudentStats();
}
