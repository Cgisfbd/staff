import 'package:equatable/equatable.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

abstract class ClassState extends Equatable {
  const ClassState();

  @override
  List<Object?> get props => [];
}

class ClassInitial extends ClassState {
  const ClassInitial();
}

class ClassLoading extends ClassState {
  const ClassLoading();
}

class ClassLoaded extends ClassState {
  const ClassLoaded({
    required this.classes,
    required this.courses,
    this.selectedCourseId = 'ALL',
    this.searchQuery = '',
    this.expandedClassId,
    this.actionSuccessMessage,
  });

  final List<ClassEntity> classes;
  final List<CourseEntity> courses;
  final String selectedCourseId;
  final String searchQuery;
  final String? expandedClassId;
  final String? actionSuccessMessage;

  List<ClassEntity> get filteredClasses {
    var list = classes;
    if (selectedCourseId != 'ALL') {
      list = list.where((c) => c.courseId == selectedCourseId).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((c) {
        final matchEn = c.nameEnglish.toLowerCase().contains(q);
        final matchUr = c.nameUrdu?.toLowerCase().contains(q) ?? false;
        final matchCourse = c.courseName.toLowerCase().contains(q);
        return matchEn || matchUr || matchCourse;
      }).toList();
    }
    return list;
  }

  int get totalCapacity => filteredClasses.fold(0, (sum, c) => sum + c.capacity);
  int get totalStudents => filteredClasses.fold(0, (sum, c) => sum + c.studentCount);
  int get totalSubjects => filteredClasses.fold(0, (sum, c) => sum + c.subjectCount);

  ClassLoaded copyWith({
    List<ClassEntity>? classes,
    List<CourseEntity>? courses,
    String? selectedCourseId,
    String? searchQuery,
    String? Function()? expandedClassId,
    String? Function()? actionSuccessMessage,
  }) {
    return ClassLoaded(
      classes: classes ?? this.classes,
      courses: courses ?? this.courses,
      selectedCourseId: selectedCourseId ?? this.selectedCourseId,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedClassId: expandedClassId != null ? expandedClassId() : this.expandedClassId,
      actionSuccessMessage: actionSuccessMessage != null ? actionSuccessMessage() : null,
    );
  }

  @override
  List<Object?> get props => [
        classes,
        courses,
        selectedCourseId,
        searchQuery,
        expandedClassId,
        actionSuccessMessage,
      ];
}

class ClassError extends ClassState {
  const ClassError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
