import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/books/domain/repositories/book_repository.dart';

class GetBooksUseCase {
  const GetBooksUseCase(this.repository);
  final BookRepository repository;

  Future<List<BookEntity>> call({
    String? courseId,
    String? classId,
    String? subjectId,
    String? term,
    String? category,
  }) {
    return repository.getBooks(
      courseId: courseId,
      classId: classId,
      subjectId: subjectId,
      term: term,
      category: category,
    );
  }
}

class CreateBookUseCase {
  const CreateBookUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity> call({
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
    return repository.createBook(
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
}

class UpdateBookUseCase {
  const UpdateBookUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity> call({
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
    return repository.updateBook(
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
}

class DeleteBookUseCase {
  const DeleteBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call({
    required String id,
    required String pin,
  }) {
    return repository.deleteBook(id: id, pin: pin);
  }
}
