import 'package:equatable/equatable.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

abstract class ExamSettingsState extends Equatable {
  const ExamSettingsState();

  @override
  List<Object?> get props => [];
}

class ExamSettingsInitial extends ExamSettingsState {
  const ExamSettingsInitial();
}

class ExamSettingsLoading extends ExamSettingsState {
  const ExamSettingsLoading();
}

class ExamSettingsLoaded extends ExamSettingsState {
  const ExamSettingsLoaded({
    required this.courses,
    required this.classes,
    required this.subjects,
    this.books = const [],
    this.selectedCourseId,
    this.selectedClassId,
    this.selectedSubjectId,
    this.isLoadingBooks = false,
    this.isUpdating = false,
    this.message,
  });

  final List<CourseEntity> courses;
  final List<ClassEntity> classes;
  final List<SubjectEntity> subjects;
  final List<BookEntity> books;
  final String? selectedCourseId;
  final String? selectedClassId;
  final String? selectedSubjectId;
  final bool isLoadingBooks;
  final bool isUpdating;
  final String? message;

  // Filtered classes by selected course
  List<ClassEntity> get filteredClasses {
    if (selectedCourseId == null || selectedCourseId!.isEmpty) {
      return classes;
    }
    return classes.where((c) => c.courseId == selectedCourseId).toList();
  }

  // Filtered subjects by selected class
  List<SubjectEntity> get filteredSubjects {
    if (selectedClassId == null || selectedClassId!.isEmpty) {
      return subjects;
    }
    return subjects.where((s) => s.classId == selectedClassId).toList();
  }

  ExamSettingsLoaded copyWith({
    List<CourseEntity>? courses,
    List<ClassEntity>? classes,
    List<SubjectEntity>? subjects,
    List<BookEntity>? books,
    String? selectedCourseId,
    String? selectedClassId,
    String? selectedSubjectId,
    bool? isLoadingBooks,
    bool? isUpdating,
    String? message,
    bool clearCourse = false,
    bool clearClass = false,
    bool clearSubject = false,
  }) {
    return ExamSettingsLoaded(
      courses: courses ?? this.courses,
      classes: classes ?? this.classes,
      subjects: subjects ?? this.subjects,
      books: books ?? this.books,
      selectedCourseId: clearCourse ? null : (selectedCourseId ?? this.selectedCourseId),
      selectedClassId: clearClass ? null : (selectedClassId ?? this.selectedClassId),
      selectedSubjectId: clearSubject ? null : (selectedSubjectId ?? this.selectedSubjectId),
      isLoadingBooks: isLoadingBooks ?? this.isLoadingBooks,
      isUpdating: isUpdating ?? this.isUpdating,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        courses,
        classes,
        subjects,
        books,
        selectedCourseId,
        selectedClassId,
        selectedSubjectId,
        isLoadingBooks,
        isUpdating,
        message,
      ];
}

class ExamSettingsError extends ExamSettingsState {
  const ExamSettingsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
