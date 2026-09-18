import 'package:staff_app/features/students/data/datasources/student_directory_remote_datasource.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/domain/repositories/student_directory_repository.dart';

class StudentDirectoryRepositoryImpl implements StudentDirectoryRepository {
  const StudentDirectoryRepositoryImpl({
    required StudentDirectoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StudentDirectoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<StudentDirectoryEntity>> getStudents({
    String? search,
    String? status,
    String? courseId,
    String? classId,
    String? modeOfStudy,
    int page = 1,
    int limit = 100,
  }) {
    return _remoteDataSource.getStudents(
      search: search,
      status: status,
      courseId: courseId,
      classId: classId,
      modeOfStudy: modeOfStudy,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<StudentStatsEntity> getStudentStats() {
    return _remoteDataSource.getStudentStats();
  }
}
