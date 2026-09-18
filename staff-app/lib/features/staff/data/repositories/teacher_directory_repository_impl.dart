import 'package:staff_app/features/staff/data/datasources/teacher_directory_remote_datasource.dart';
import 'package:staff_app/features/staff/data/models/teacher_directory_model.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';
import 'package:staff_app/features/staff/domain/repositories/teacher_directory_repository.dart';

class TeacherDirectoryRepositoryImpl implements TeacherDirectoryRepository {
  const TeacherDirectoryRepositoryImpl({required TeacherDirectoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final TeacherDirectoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<TeacherDirectoryEntity>> getTeachers({
    String? search,
    String? designation,
    String? qualification,
    String? dutyMode,
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    return _remoteDataSource.getTeachers(
      search: search,
      designation: designation,
      qualification: qualification,
      dutyMode: dutyMode,
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<TeacherStatsEntity> getTeacherStats() async {
    return _remoteDataSource.getTeacherStats();
  }

  @override
  Future<TeacherDirectoryEntity> createTeacher(TeacherDirectoryEntity teacher) async {
    final model = TeacherDirectoryModel.fromEntity(teacher);
    return _remoteDataSource.createTeacher(model);
  }

  @override
  Future<TeacherDirectoryEntity> updateTeacher(TeacherDirectoryEntity teacher) async {
    final model = TeacherDirectoryModel.fromEntity(teacher);
    return _remoteDataSource.updateTeacher(model);
  }

  @override
  Future<void> deleteTeacher(String id) async {
    return _remoteDataSource.deleteTeacher(id);
  }
}
