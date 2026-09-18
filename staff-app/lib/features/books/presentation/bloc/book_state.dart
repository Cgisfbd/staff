import 'package:equatable/equatable.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {
  const BookInitial();
}

class BookLoading extends BookState {
  const BookLoading();
}

class BookLoaded extends BookState {
  const BookLoaded({
    required this.books,
    required this.filteredBooks,
    required this.subjects,
    this.selectedSubjectId,
    this.selectedTerm = 'ALL',
    this.selectedCategory = 'ALL',
    this.searchQuery = '',
    this.isMutating = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<BookEntity> books;
  final List<BookEntity> filteredBooks;
  final List<SubjectEntity> subjects;
  final String? selectedSubjectId;
  final String selectedTerm;
  final String selectedCategory;
  final String searchQuery;
  final bool isMutating;
  final String? errorMessage;
  final String? successMessage;

  BookLoaded copyWith({
    List<BookEntity>? books,
    List<BookEntity>? filteredBooks,
    List<SubjectEntity>? subjects,
    String? selectedSubjectId,
    String? selectedTerm,
    String? selectedCategory,
    String? searchQuery,
    bool? isMutating,
    String? errorMessage,
    String? successMessage,
    bool clearSubjectFilter = false,
  }) {
    return BookLoaded(
      books: books ?? this.books,
      filteredBooks: filteredBooks ?? this.filteredBooks,
      subjects: subjects ?? this.subjects,
      selectedSubjectId: clearSubjectFilter ? null : (selectedSubjectId ?? this.selectedSubjectId),
      selectedTerm: selectedTerm ?? this.selectedTerm,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        books,
        filteredBooks,
        subjects,
        selectedSubjectId,
        selectedTerm,
        selectedCategory,
        searchQuery,
        isMutating,
        errorMessage,
        successMessage,
      ];
}

class BookError extends BookState {
  const BookError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
