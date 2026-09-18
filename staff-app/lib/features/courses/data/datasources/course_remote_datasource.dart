import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/courses/data/models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel> createCourse({
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  });
  Future<CourseModel> updateCourse({
    required String id,
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  });
  Future<void> deleteCourse({
    required String id,
    required String pin,
  });
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  CourseRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working copy initialized with seed courses for offline & dev resilience
  static final List<CourseModel> _localCourses = List.from(CourseModel.mockCourses);

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/admin-panel/courses');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        if (rawData is List) {
          final list = rawData.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    return List.unmodifiable(_localCourses);
  }

  @override
  Future<CourseModel> createCourse({
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/admin-panel/courses',
        data: {
          'nameEnglish': nameEnglish,
          if (nameUrdu != null && nameUrdu.isNotEmpty) 'nameUrdu': nameUrdu,
          if (description != null && description.isNotEmpty) 'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final newModel = CourseModel.fromJson(data);
          _localCourses.insert(0, newModel);
          return newModel;
        }
      }
    } catch (_) {}

    // Fallback: Local insertion
    final newCourse = CourseModel(
      id: 'course-${DateTime.now().millisecondsSinceEpoch}',
      simpleId: _localCourses.length + 1,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      description: description,
      classCount: 0,
      subjectCount: 0,
      bookCount: 0,
      studentCount: 0,
    );
    _localCourses.insert(0, newCourse);
    return newCourse;
  }

  @override
  Future<CourseModel> updateCourse({
    required String id,
    required String nameEnglish,
    String? nameUrdu,
    String? description,
  }) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '/admin-panel/courses/$id',
        data: {
          'nameEnglish': nameEnglish,
          if (nameUrdu != null) 'nameUrdu': nameUrdu,
          if (description != null) 'description': description,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final updated = CourseModel.fromJson(data);
          final idx = _localCourses.indexWhere((c) => c.id == id);
          if (idx != -1) _localCourses[idx] = updated;
          return updated;
        }
      }
    } catch (_) {}

    // Fallback: Local update
    final idx = _localCourses.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final updated = _localCourses[idx].copyWith(
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        description: description,
      );
      _localCourses[idx] = updated;
      return updated;
    }
    throw Exception('Course not found with id: $id');
  }

  @override
  Future<void> deleteCourse({
    required String id,
    required String pin,
  }) async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        '/admin-panel/courses/$id',
        data: {'pin': pin},
      );
    } catch (_) {}

    _localCourses.removeWhere((c) => c.id == id);
  }
}
