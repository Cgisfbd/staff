import 'package:equatable/equatable.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseLoaded extends CourseState {
  const CourseLoaded({
    required this.courses,
    required this.filteredCourses,
    this.expandedCourseId,
    this.searchQuery = '',
    this.isActionLoading = false,
    this.actionSuccessMessage,
  });

  final List<CourseEntity> courses;
  final List<CourseEntity> filteredCourses;
  final String? expandedCourseId;
  final String searchQuery;
  final bool isActionLoading;
  final String? actionSuccessMessage;

  int get totalClasses => courses.fold(0, (acc, c) => acc + c.classCount);
  int get totalStudents => courses.fold(0, (acc, c) => acc + c.studentCount);
  int get totalSubjects => courses.fold(0, (acc, c) => acc + c.subjectCount);
  int get totalBooks => courses.fold(0, (acc, c) => acc + c.bookCount);

  CourseLoaded copyWith({
    List<CourseEntity>? courses,
    List<CourseEntity>? filteredCourses,
    String? Function()? expandedCourseId,
    String? searchQuery,
    bool? isActionLoading,
    String? actionSuccessMessage,
  }) {
    return CourseLoaded(
      courses: courses ?? this.courses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      expandedCourseId: expandedCourseId != null ? expandedCourseId() : this.expandedCourseId,
      searchQuery: searchQuery ?? this.searchQuery,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        courses,
        filteredCourses,
        expandedCourseId,
        searchQuery,
        isActionLoading,
        actionSuccessMessage,
      ];
}

class CourseError extends CourseState {
  const CourseError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
