import 'package:staff_app/features/books/domain/entities/book_entity.dart';

abstract class BookRepository {
  Future<List<BookEntity>> getBooks({
    String? courseId,
    String? classId,
    String? subjectId,
    String? term,
    String? category,
  });

  Future<BookEntity> createBook({
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

  Future<BookEntity> updateBook({
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
