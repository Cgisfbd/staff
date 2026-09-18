import 'package:equatable/equatable.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {
  const SubjectInitial();
}

class SubjectLoading extends SubjectState {
  const SubjectLoading();
}

class SubjectLoaded extends SubjectState {
  const SubjectLoaded({
    required this.subjects,
    required this.filteredSubjects,
    required this.courses,
    required this.classes,
    this.selectedCourseId,
    this.selectedClassId,
    this.searchQuery = '',
    this.isMutating = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<SubjectEntity> subjects;
  final List<SubjectEntity> filteredSubjects;
  final List<CourseEntity> courses;
  final List<ClassEntity> classes;
  final String? selectedCourseId;
  final String? selectedClassId;
  final String searchQuery;
  final bool isMutating;
  final String? errorMessage;
  final String? successMessage;

  SubjectLoaded copyWith({
    List<SubjectEntity>? subjects,
    List<SubjectEntity>? filteredSubjects,
    List<CourseEntity>? courses,
    List<ClassEntity>? classes,
    String? selectedCourseId,
    String? selectedClassId,
    String? searchQuery,
    bool? isMutating,
    String? errorMessage,
    String? successMessage,
    bool clearCourseFilter = false,
    bool clearClassFilter = false,
  }) {
    return SubjectLoaded(
      subjects: subjects ?? this.subjects,
      filteredSubjects: filteredSubjects ?? this.filteredSubjects,
      courses: courses ?? this.courses,
      classes: classes ?? this.classes,
      selectedCourseId: clearCourseFilter ? null : (selectedCourseId ?? this.selectedCourseId),
      selectedClassId: clearClassFilter ? null : (selectedClassId ?? this.selectedClassId),
      searchQuery: searchQuery ?? this.searchQuery,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        subjects,
        filteredSubjects,
        courses,
        classes,
        selectedCourseId,
        selectedClassId,
        searchQuery,
        isMutating,
        errorMessage,
        successMessage,
      ];
}

class SubjectError extends SubjectState {
  const SubjectError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
