import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/books/domain/usecases/book_usecases.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/domain/usecases/get_classes_usecase.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_event.dart';
import 'package:staff_app/features/exam_settings/presentation/bloc/exam_settings_state.dart';
import 'package:staff_app/features/subjects/domain/usecases/subject_usecases.dart';

class ExamSettingsBloc extends Bloc<ExamSettingsEvent, ExamSettingsState> {
  ExamSettingsBloc({
    required this.getCoursesUseCase,
    required this.getClassesUseCase,
    required this.getSubjectsUseCase,
    required this.getBooksUseCase,
    required this.updateBookUseCase,
  }) : super(const ExamSettingsInitial()) {
    on<LoadExamSettingsInitialEvent>(_onLoadInitial);
    on<SelectCourseEvent>(_onSelectCourse);
    on<SelectClassEvent>(_onSelectClass);
    on<SelectSubjectEvent>(_onSelectSubject);
    on<LoadBooksForSubjectEvent>(_onLoadBooks);
    on<UpdateBookExamSettingsEvent>(_onUpdateBook);
  }

  final GetCoursesUseCase getCoursesUseCase;
  final GetClassesUseCase getClassesUseCase;
  final GetSubjectsUseCase getSubjectsUseCase;
  final GetBooksUseCase getBooksUseCase;
  final UpdateBookUseCase updateBookUseCase;

  Future<void> _onLoadInitial(
    LoadExamSettingsInitialEvent event,
    Emitter<ExamSettingsState> emit,
  ) async {
    emit(const ExamSettingsLoading());
    try {
      final coursesRes = await getCoursesUseCase();
      final courses = coursesRes.fold((_) => <CourseEntity>[], (c) => c);

      final classesRes = await getClassesUseCase();
      final classes = classesRes.fold((_) => <ClassEntity>[], (cl) => cl);

      final subjects = await getSubjectsUseCase();

      emit(ExamSettingsLoaded(
        courses: courses,
        classes: classes,
        subjects: subjects,
        books: const [],
      ));
    } catch (e) {
      emit(ExamSettingsError('Failed to load initial exam settings data: $e'));
    }
  }

  void _onSelectCourse(
    SelectCourseEvent event,
    Emitter<ExamSettingsState> emit,
  ) {
    if (state is! ExamSettingsLoaded) return;
    final curr = state as ExamSettingsLoaded;

    emit(curr.copyWith(
      selectedCourseId: event.courseId,
      clearClass: true,
      clearSubject: true,
      books: const [],
    ));
  }

  void _onSelectClass(
    SelectClassEvent event,
    Emitter<ExamSettingsState> emit,
  ) {
    if (state is! ExamSettingsLoaded) return;
    final curr = state as ExamSettingsLoaded;

    emit(curr.copyWith(
      selectedClassId: event.classId,
      clearSubject: true,
      books: const [],
    ));
  }

  void _onSelectSubject(
    SelectSubjectEvent event,
    Emitter<ExamSettingsState> emit,
  ) {
    if (state is! ExamSettingsLoaded) return;
    final curr = state as ExamSettingsLoaded;

    emit(curr.copyWith(
      selectedSubjectId: event.subjectId,
      books: const [],
    ));
  }

  Future<void> _onLoadBooks(
    LoadBooksForSubjectEvent event,
    Emitter<ExamSettingsState> emit,
  ) async {
    if (state is! ExamSettingsLoaded) return;
    final curr = state as ExamSettingsLoaded;

    emit(curr.copyWith(isLoadingBooks: true));
    try {
      final books = await getBooksUseCase(subjectId: event.subjectId);
      emit(curr.copyWith(
        books: books,
        isLoadingBooks: false,
      ));
    } catch (e) {
      emit(curr.copyWith(
        isLoadingBooks: false,
        message: 'Could not load books: $e',
      ));
    }
  }

  Future<void> _onUpdateBook(
    UpdateBookExamSettingsEvent event,
    Emitter<ExamSettingsState> emit,
  ) async {
    if (state is! ExamSettingsLoaded) return;
    final curr = state as ExamSettingsLoaded;

    emit(curr.copyWith(isUpdating: true));
    try {
      final updatedBook = await updateBookUseCase(
        id: event.book.id,
        subjectId: event.book.subjectId,
        nameEnglish: event.book.nameEnglish,
        nameUrdu: event.book.nameUrdu,
        category: event.book.category,
        term: event.term,
        maxMarks: event.maxMarks,
        passMarks: event.passMarks,
        theoryMarks: event.theoryMarks,
        practicalMarks: event.practicalMarks,
      );

      final updatedList = curr.books.map((b) {
        return b.id == updatedBook.id ? updatedBook : b;
      }).toList();

      emit(curr.copyWith(
        books: updatedList,
        isUpdating: false,
        message: 'Exam settings saved for "${event.book.nameEnglish}"',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isUpdating: false,
        message: 'Failed to update exam settings: $e',
      ));
    }
  }
}
