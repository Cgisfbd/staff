import 'package:equatable/equatable.dart';
import 'package:staff_app/features/books/domain/entities/book_entity.dart';

abstract class ExamSettingsEvent extends Equatable {
  const ExamSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadExamSettingsInitialEvent extends ExamSettingsEvent {
  const LoadExamSettingsInitialEvent();
}

class SelectCourseEvent extends ExamSettingsEvent {
  const SelectCourseEvent(this.courseId);
  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class SelectClassEvent extends ExamSettingsEvent {
  const SelectClassEvent(this.classId);
  final String classId;

  @override
  List<Object?> get props => [classId];
}

class SelectSubjectEvent extends ExamSettingsEvent {
  const SelectSubjectEvent(this.subjectId);
  final String subjectId;

  @override
  List<Object?> get props => [subjectId];
}

class LoadBooksForSubjectEvent extends ExamSettingsEvent {
  const LoadBooksForSubjectEvent(this.subjectId);
  final String subjectId;

  @override
  List<Object?> get props => [subjectId];
}

class UpdateBookExamSettingsEvent extends ExamSettingsEvent {
  const UpdateBookExamSettingsEvent({
    required this.book,
    required this.term,
    required this.maxMarks,
    required this.passMarks,
    required this.practicalMarks,
    required this.theoryMarks,
  });

  final BookEntity book;
  final String term;
  final int maxMarks;
  final int passMarks;
  final int practicalMarks;
  final int theoryMarks;

  @override
  List<Object?> get props => [
        book,
        term,
        maxMarks,
        passMarks,
        practicalMarks,
        theoryMarks,
      ];
}
