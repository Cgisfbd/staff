import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/books/domain/usecases/book_usecases.dart';
import 'package:staff_app/features/books/presentation/bloc/book_event.dart';
import 'package:staff_app/features/books/presentation/bloc/book_state.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:staff_app/features/subjects/domain/usecases/subject_usecases.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc({
    required this.getBooksUseCase,
    required this.createBookUseCase,
    required this.updateBookUseCase,
    required this.deleteBookUseCase,
    required this.getSubjectsUseCase,
  }) : super(const BookInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<FilterSubjectSelectedEvent>(_onFilterSubjectSelected);
    on<FilterTermSelectedEvent>(_onFilterTermSelected);
    on<FilterCategorySelectedEvent>(_onFilterCategorySelected);
    on<SearchBooksEvent>(_onSearchBooks);
    on<CreateBookEvent>(_onCreateBook);
    on<UpdateBookEvent>(_onUpdateBook);
    on<DeleteBookEvent>(_onDeleteBook);
  }

  final GetBooksUseCase getBooksUseCase;
  final CreateBookUseCase createBookUseCase;
  final UpdateBookUseCase updateBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;
  final GetSubjectsUseCase getSubjectsUseCase;

  List<BookEntity> _allBooks = [];
  List<SubjectEntity> _allSubjects = [];

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(const BookLoading());
    try {
      final results = await Future.wait([
        getBooksUseCase(
          subjectId: event.subjectId,
          term: event.term,
          category: event.category,
        ),
        getSubjectsUseCase(),
      ]);

      _allBooks = results[0] as List<BookEntity>;
      _allSubjects = results[1] as List<SubjectEntity>;

      final filtered = _applyFilters(
        books: _allBooks,
        subjectId: event.subjectId,
        term: event.term ?? 'ALL',
        category: event.category ?? 'ALL',
        query: '',
      );

      emit(BookLoaded(
        books: _allBooks,
        filteredBooks: filtered,
        subjects: _allSubjects,
        selectedSubjectId: event.subjectId,
        selectedTerm: event.term ?? 'ALL',
        selectedCategory: event.category ?? 'ALL',
      ));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  void _onFilterSubjectSelected(
    FilterSubjectSelectedEvent event,
    Emitter<BookState> emit,
  ) {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;

    final newSubjectId = (event.subjectId == 'ALL' || event.subjectId == curr.selectedSubjectId)
        ? null
        : event.subjectId;

    final filtered = _applyFilters(
      books: _allBooks,
      subjectId: newSubjectId,
      term: curr.selectedTerm,
      category: curr.selectedCategory,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      filteredBooks: filtered,
      selectedSubjectId: newSubjectId,
      clearSubjectFilter: newSubjectId == null,
    ));
  }

  void _onFilterTermSelected(
    FilterTermSelectedEvent event,
    Emitter<BookState> emit,
  ) {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;

    final filtered = _applyFilters(
      books: _allBooks,
      subjectId: curr.selectedSubjectId,
      term: event.term,
      category: curr.selectedCategory,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      filteredBooks: filtered,
      selectedTerm: event.term,
    ));
  }

  void _onFilterCategorySelected(
    FilterCategorySelectedEvent event,
    Emitter<BookState> emit,
  ) {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;

    final filtered = _applyFilters(
      books: _allBooks,
      subjectId: curr.selectedSubjectId,
      term: curr.selectedTerm,
      category: event.category,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      filteredBooks: filtered,
      selectedCategory: event.category,
    ));
  }

  void _onSearchBooks(
    SearchBooksEvent event,
    Emitter<BookState> emit,
  ) {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;

    final filtered = _applyFilters(
      books: _allBooks,
      subjectId: curr.selectedSubjectId,
      term: curr.selectedTerm,
      category: curr.selectedCategory,
      query: event.query,
    );

    emit(curr.copyWith(
      filteredBooks: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onCreateBook(
    CreateBookEvent event,
    Emitter<BookState> emit,
  ) async {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;
    emit(curr.copyWith(isMutating: true));

    try {
      final created = await createBookUseCase(
        subjectId: event.subjectId,
        nameEnglish: event.nameEnglish,
        nameUrdu: event.nameUrdu,
        category: event.category,
        term: event.term,
        maxMarks: event.maxMarks,
        passMarks: event.passMarks,
        theoryMarks: event.theoryMarks,
        practicalMarks: event.practicalMarks,
      );

      _allBooks = [created, ..._allBooks];
      final filtered = _applyFilters(
        books: _allBooks,
        subjectId: curr.selectedSubjectId,
        term: curr.selectedTerm,
        category: curr.selectedCategory,
        query: curr.searchQuery,
      );

      emit(curr.copyWith(
        books: _allBooks,
        filteredBooks: filtered,
        isMutating: false,
        successMessage: 'Book "${created.nameEnglish}" added successfully',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isMutating: false,
        errorMessage: 'Failed to add book: $e',
      ));
    }
  }

  Future<void> _onUpdateBook(
    UpdateBookEvent event,
    Emitter<BookState> emit,
  ) async {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;
    emit(curr.copyWith(isMutating: true));

    try {
      final updated = await updateBookUseCase(
        id: event.id,
        subjectId: event.subjectId,
        nameEnglish: event.nameEnglish,
        nameUrdu: event.nameUrdu,
        category: event.category,
        term: event.term,
        maxMarks: event.maxMarks,
        passMarks: event.passMarks,
        theoryMarks: event.theoryMarks,
        practicalMarks: event.practicalMarks,
      );

      _allBooks = _allBooks.map((b) => b.id == updated.id ? updated : b).toList();
      final filtered = _applyFilters(
        books: _allBooks,
        subjectId: curr.selectedSubjectId,
        term: curr.selectedTerm,
        category: curr.selectedCategory,
        query: curr.searchQuery,
      );

      emit(curr.copyWith(
        books: _allBooks,
        filteredBooks: filtered,
        isMutating: false,
        successMessage: 'Book "${updated.nameEnglish}" updated successfully',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isMutating: false,
        errorMessage: 'Failed to update book: $e',
      ));
    }
  }

  Future<void> _onDeleteBook(
    DeleteBookEvent event,
    Emitter<BookState> emit,
  ) async {
    if (state is! BookLoaded) return;
    final curr = state as BookLoaded;
    emit(curr.copyWith(isMutating: true));

    try {
      await deleteBookUseCase(id: event.id, pin: event.pin);

      _allBooks = _allBooks.where((b) => b.id != event.id).toList();
      final filtered = _applyFilters(
        books: _allBooks,
        subjectId: curr.selectedSubjectId,
        term: curr.selectedTerm,
        category: curr.selectedCategory,
        query: curr.searchQuery,
      );

      emit(curr.copyWith(
        books: _allBooks,
        filteredBooks: filtered,
        isMutating: false,
        successMessage: 'Book deleted successfully',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isMutating: false,
        errorMessage: 'Failed to delete book: $e',
      ));
    }
  }

  List<BookEntity> _applyFilters({
    required List<BookEntity> books,
    String? subjectId,
    required String term,
    required String category,
    required String query,
  }) {
    return books.where((b) {
      if (subjectId != null && subjectId.isNotEmpty && b.subjectId != subjectId) {
        return false;
      }
      if (term != 'ALL' && b.term != term) {
        return false;
      }
      if (category != 'ALL' && b.category != category) {
        return false;
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchEn = b.nameEnglish.toLowerCase().contains(q);
        final matchUr = b.nameUrdu.toLowerCase().contains(q);
        final matchSub = (b.subjectName ?? '').toLowerCase().contains(q);
        if (!matchEn && !matchUr && !matchSub) return false;
      }
      return true;
    }).toList();
  }
}
