import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/subjects/data/models/subject_model.dart';

abstract class SubjectRemoteDataSource {
  Future<List<SubjectModel>> getSubjects({String? courseId, String? classId});
  Future<SubjectModel> createSubject({
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  });
  Future<SubjectModel> updateSubject({
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

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  SubjectRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working copy initialized with seed subjects for offline & dev resilience
  static final List<SubjectModel> _localSubjects = List.from(SubjectModel.mockSubjects);

  @override
  Future<List<SubjectModel>> getSubjects({String? courseId, String? classId}) async {
    try {
      final queryParams = <String>[];
      if (courseId != null && courseId.isNotEmpty && courseId != 'ALL') {
        queryParams.add('courseId=$courseId');
      }
      if (classId != null && classId.isNotEmpty && classId != 'ALL') {
        queryParams.add('classId=$classId');
      }

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await apiClient.get<Map<String, dynamic>>('/admin-panel/subjects$queryString');

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        if (rawData is List) {
          final list = rawData.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}

    // Fallback filter on local list
    var filtered = List<SubjectModel>.from(_localSubjects);
    if (classId != null && classId.isNotEmpty && classId != 'ALL') {
      filtered = filtered.where((s) => s.classId == classId).toList();
    } else if (courseId != null && courseId.isNotEmpty && courseId != 'ALL') {
      filtered = filtered.where((s) => s.courseId == courseId).toList();
    }
    return List.unmodifiable(filtered);
  }

  @override
  Future<SubjectModel> createSubject({
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/admin-panel/subjects',
        data: {
          'classId': classId,
          'nameEnglish': nameEnglish,
          'nameUrdu': nameUrdu,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final newModel = SubjectModel.fromJson(data);
          _localSubjects.insert(0, newModel);
          return newModel;
        }
      }
    } catch (_) {}

    final newSubject = SubjectModel(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      simpleId: _localSubjects.length + 1,
      classId: classId,
      className: 'Academic Class',
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      bookCount: 0,
    );
    _localSubjects.insert(0, newSubject);
    return newSubject;
  }

  @override
  Future<SubjectModel> updateSubject({
    required String id,
    required String classId,
    required String nameEnglish,
    required String nameUrdu,
  }) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '/admin-panel/subjects/$id',
        data: {
          'classId': classId,
          'nameEnglish': nameEnglish,
          'nameUrdu': nameUrdu,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final updated = SubjectModel.fromJson(data);
          final idx = _localSubjects.indexWhere((s) => s.id == id);
          if (idx != -1) _localSubjects[idx] = updated;
          return updated;
        }
      }
    } catch (_) {}

    final idx = _localSubjects.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final existing = _localSubjects[idx];
      final updated = SubjectModel(
        id: existing.id,
        simpleId: existing.simpleId,
        classId: classId,
        className: existing.className,
        courseId: existing.courseId,
        courseName: existing.courseName,
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        bookCount: existing.bookCount,
      );
      _localSubjects[idx] = updated;
      return updated;
    }

    return SubjectModel(
      id: id,
      simpleId: 1,
      classId: classId,
      className: 'Academic Class',
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
    );
  }

  @override
  Future<void> deleteSubject({
    required String id,
    required String pin,
  }) async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        '/admin-panel/subjects/$id',
        data: {'pin': pin},
      );
    } catch (_) {}

    _localSubjects.removeWhere((s) => s.id == id);
  }
}
