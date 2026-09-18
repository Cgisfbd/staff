import 'package:staff_app/features/books/data/datasources/book_remote_datasource.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/books/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({required this.remoteDataSource});

  final BookRemoteDataSource remoteDataSource;

  @override
  Future<List<BookEntity>> getBooks({
    String? courseId,
    String? classId,
    String? subjectId,
    String? term,
    String? category,
  }) {
    return remoteDataSource.getBooks(
      courseId: courseId,
      classId: classId,
      subjectId: subjectId,
      term: term,
      category: category,
    );
  }

  @override
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
  }) {
    return remoteDataSource.createBook(
      subjectId: subjectId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      category: category,
      term: term,
      maxMarks: maxMarks,
      passMarks: passMarks,
      theoryMarks: theoryMarks,
      practicalMarks: practicalMarks,
    );
  }

  @override
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
  }) {
    return remoteDataSource.updateBook(
      id: id,
      subjectId: subjectId,
      nameEnglish: nameEnglish,
      nameUrdu: nameUrdu,
      category: category,
      term: term,
      maxMarks: maxMarks,
      passMarks: passMarks,
      theoryMarks: theoryMarks,
      practicalMarks: practicalMarks,
    );
  }

  @override
  Future<void> deleteBook({
    required String id,
    required String pin,
  }) {
    return remoteDataSource.deleteBook(id: id, pin: pin);
  }
}
