import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';

abstract class TeacherDirectoryRepository {
  Future<List<TeacherDirectoryEntity>> getTeachers({
    String? search,
    String? designation,
    String? qualification,
    String? dutyMode,
    String? status,
    int page = 1,
    int limit = 100,
  });

  Future<TeacherStatsEntity> getTeacherStats();

  Future<TeacherDirectoryEntity> createTeacher(TeacherDirectoryEntity teacher);

  Future<TeacherDirectoryEntity> updateTeacher(TeacherDirectoryEntity teacher);

  Future<void> deleteTeacher(String id);
}
