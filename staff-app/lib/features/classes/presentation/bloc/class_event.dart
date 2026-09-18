import 'package:equatable/equatable.dart';

abstract class ClassEvent extends Equatable {
  const ClassEvent();

  @override
  List<Object?> get props => [];
}

class LoadClassesEvent extends ClassEvent {
  const LoadClassesEvent({this.courseId, this.searchQuery});

  final String? courseId;
  final String? searchQuery;

  @override
  List<Object?> get props => [courseId, searchQuery];
}

class SelectCourseFilterEvent extends ClassEvent {
  const SelectCourseFilterEvent(this.courseId);

  final String courseId; // 'ALL' or specific courseId

  @override
  List<Object?> get props => [courseId];
}

class ToggleExpandClassEvent extends ClassEvent {
  const ToggleExpandClassEvent(this.classId);

  final String classId;

  @override
  List<Object?> get props => [classId];
}

class CreateClassEvent extends ClassEvent {
  const CreateClassEvent({
    required this.courseId,
    required this.nameEnglish,
    this.nameUrdu,
    this.capacity,
  });

  final String courseId;
  final String nameEnglish;
  final String? nameUrdu;
  final int? capacity;

  @override
  List<Object?> get props => [courseId, nameEnglish, nameUrdu, capacity];
}

class UpdateClassEvent extends ClassEvent {
  const UpdateClassEvent({
    required this.id,
    this.courseId,
    required this.nameEnglish,
    this.nameUrdu,
    this.capacity,
  });

  final String id;
  final String? courseId;
  final String nameEnglish;
  final String? nameUrdu;
  final int? capacity;

  @override
  List<Object?> get props => [id, courseId, nameEnglish, nameUrdu, capacity];
}

class DeleteClassEvent extends ClassEvent {
  const DeleteClassEvent({
    required this.id,
    required this.pin,
  });

  final String id;
  final String pin;

  @override
  List<Object?> get props => [id, pin];
}
