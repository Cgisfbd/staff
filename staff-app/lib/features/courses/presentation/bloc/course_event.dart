import 'package:equatable/equatable.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCoursesEvent extends CourseEvent {
  const LoadCoursesEvent({this.searchQuery});

  final String? searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

class ToggleExpandCourseEvent extends CourseEvent {
  const ToggleExpandCourseEvent(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class CreateCourseEvent extends CourseEvent {
  const CreateCourseEvent({
    required this.nameEnglish,
    this.nameUrdu,
    this.description,
  });

  final String nameEnglish;
  final String? nameUrdu;
  final String? description;

  @override
  List<Object?> get props => [nameEnglish, nameUrdu, description];
}

class UpdateCourseEvent extends CourseEvent {
  const UpdateCourseEvent({
    required this.id,
    required this.nameEnglish,
    this.nameUrdu,
    this.description,
  });

  final String id;
  final String nameEnglish;
  final String? nameUrdu;
  final String? description;

  @override
  List<Object?> get props => [id, nameEnglish, nameUrdu, description];
}

class DeleteCourseEvent extends CourseEvent {
  const DeleteCourseEvent({
    required this.id,
    required this.pin,
  });

  final String id;
  final String pin;

  @override
  List<Object?> get props => [id, pin];
}
