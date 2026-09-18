import 'package:equatable/equatable.dart';

abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubjectsEvent extends SubjectEvent {
  const LoadSubjectsEvent({this.courseId, this.classId});

  final String? courseId;
  final String? classId;

  @override
  List<Object?> get props => [courseId, classId];
}

class FilterCourseSelectedEvent extends SubjectEvent {
  const FilterCourseSelectedEvent(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class FilterClassSelectedEvent extends SubjectEvent {
  const FilterClassSelectedEvent(this.classId);

  final String classId;

  @override
  List<Object?> get props => [classId];
}

class CreateSubjectEvent extends SubjectEvent {
  const CreateSubjectEvent({
    required this.classId,
    required this.nameEnglish,
    required this.nameUrdu,
  });

  final String classId;
  final String nameEnglish;
  final String nameUrdu;

  @override
  List<Object?> get props => [classId, nameEnglish, nameUrdu];
}

class UpdateSubjectEvent extends SubjectEvent {
  const UpdateSubjectEvent({
    required this.id,
    required this.classId,
    required this.nameEnglish,
    required this.nameUrdu,
  });

  final String id;
  final String classId;
  final String nameEnglish;
  final String nameUrdu;

  @override
  List<Object?> get props => [id, classId, nameEnglish, nameUrdu];
}

class DeleteSubjectEvent extends SubjectEvent {
  const DeleteSubjectEvent({
    required this.id,
    required this.pin,
  });

  final String id;
  final String pin;

  @override
  List<Object?> get props => [id, pin];
}

class SearchSubjectsEvent extends SubjectEvent {
  const SearchSubjectsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
