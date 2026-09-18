import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/books/data/models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({
    String? courseId,
    String? classId,
    String? subjectId,
    String? term,
    String? category,
  });

  Future<BookModel> createBook({
    required String subjectId,
    required String nameEnglish,
    required String nameUrdu,
    required String category,
    required String term,
    required int maxMarks,
    required int passMarks,
    required int theoryMarks,
    required int practicalMarks,
  });

  Future<BookModel> updateBook({
    required String id,
    required String subjectId,
    required String nameEnglish,
    required String nameUrdu,
    required String category,
    required String term,
    required int maxMarks,
    required int passMarks,
    required int theoryMarks,
    required int practicalMarks,
  });

  Future<void> deleteBook({
    required String id,
    required String pin,
  });
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  BookRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working copy initialized with seed books for offline & dev resilience
  static final List<BookModel> _localBooks = List.from(BookModel.mockBooks);

  @override
  Future<List<BookModel>> getBooks({
    String? courseId,
    String? classId,
    String? subjectId,
    String? term,
    String? category,
  }) async {
    try {
      final queryParams = <String>[];
      if (courseId != null && courseId.isNotEmpty && courseId != 'ALL') {
        queryParams.add('courseId=$courseId');
      }
      if (classId != null && classId.isNotEmpty && classId != 'ALL') {
        queryParams.add('classId=$classId');
      }
      if (subjectId != null && subjectId.isNotEmpty && subjectId != 'ALL') {
        queryParams.add('subjectId=$subjectId');
      }
      if (term != null && term.isNotEmpty && term != 'ALL') {
        queryParams.add('term=$term');
      }
      if (category != null && category.isNotEmpty && category != 'ALL') {
        queryParams.add('category=$category');
      }

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await apiClient.get<Map<String, dynamic>>('/admin-panel/books$queryString');

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        if (rawData is List) {
          final list = rawData.map((e) => BookModel.fromJson(e as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}

    var filtered = List<BookModel>.from(_localBooks);
    if (subjectId != null && subjectId.isNotEmpty && subjectId != 'ALL') {
      filtered = filtered.where((b) => b.subjectId == subjectId).toList();
    }
    if (term != null && term.isNotEmpty && term != 'ALL') {
      filtered = filtered.where((b) => b.term == term).toList();
    }
    if (category != null && category.isNotEmpty && category != 'ALL') {
      filtered = filtered.where((b) => b.category == category).toList();
    }
    return List.unmodifiable(filtered);
  }

  @override
  Future<BookModel> createBook({
    required String subjectId,
    required String nameEnglish,
    required String nameUrdu,
    required String category,
    required String term,
    required int maxMarks,
    required int passMarks,
    required int theoryMarks,
    required int practicalMarks,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/admin-panel/books',
        data: {
          'subjectId': subjectId,
          'nameEnglish': nameEnglish,
          'nameUrdu': nameUrdu,
          'category': category,
          'term': term,
          'maxMarks': maxMarks,
          'passMarks': passMarks,
          'theoryMarks': theoryMarks,
          'practicalMarks': practicalMarks,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final newModel = BookModel.fromJson(data);
          _localBooks.insert(0, newModel);
          return newModel;
        }
      }
    } catch (_) {}

    final newBook = BookModel(
      id: 'book-${DateTime.now().millisecondsSinceEpoch}',
      simpleId: _localBooks.length + 1,
      subjectId: subjectId,
      subjectName: 'Academic Subject',
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      category: category,
      term: term,
      maxMarks: maxMarks,
      passMarks: passMarks,
      theoryMarks: theoryMarks,
      practicalMarks: practicalMarks,
    );
    _localBooks.insert(0, newBook);
    return newBook;
  }

  @override
  Future<BookModel> updateBook({
    required String id,
    required String subjectId,
    required String nameEnglish,
    required String nameUrdu,
    required String category,
    required String term,
    required int maxMarks,
    required int passMarks,
    required int theoryMarks,
    required int practicalMarks,
  }) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '/admin-panel/books/$id',
        data: {
          'subjectId': subjectId,
          'nameEnglish': nameEnglish,
          'nameUrdu': nameUrdu,
          'category': category,
          'term': term,
          'maxMarks': maxMarks,
          'passMarks': passMarks,
          'theoryMarks': theoryMarks,
          'practicalMarks': practicalMarks,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final updated = BookModel.fromJson(data);
          final idx = _localBooks.indexWhere((b) => b.id == id);
          if (idx != -1) _localBooks[idx] = updated;
          return updated;
        }
      }
    } catch (_) {}

    final idx = _localBooks.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final existing = _localBooks[idx];
      final updated = BookModel(
        id: existing.id,
        simpleId: existing.simpleId,
        subjectId: subjectId,
        subjectName: existing.subjectName,
        className: existing.className,
        courseName: existing.courseName,
        nameEnglish: nameEnglish,
        nameUrdu: nameUrdu,
        category: category,
        term: term,
        maxMarks: maxMarks,
        passMarks: passMarks,
        theoryMarks: theoryMarks,
        practicalMarks: practicalMarks,
      );
      _localBooks[idx] = updated;
      return updated;
    }

    return BookModel(
      id: id,
      simpleId: 1,
      subjectId: subjectId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
    );
  }

  @override
  Future<void> deleteBook({
    required String id,
    required String pin,
  }) async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        '/admin-panel/books/$id',
        data: {'pin': pin},
      );
    } catch (_) {}

    _localBooks.removeWhere((b) => b.id == id);
  }
}
