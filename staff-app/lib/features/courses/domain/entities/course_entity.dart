import 'package:equatable/equatable.dart';

/// Pure domain entity representing an institutional course or academic department
class CourseEntity extends Equatable {
  const CourseEntity({
    required this.id,
    required this.simpleId,
    required this.nameEnglish,
    this.nameUrdu,
    this.description,
    this.classCount = 0,
    this.subjectCount = 0,
    this.bookCount = 0,
    this.studentCount = 0,
  });

  final String id;
  final int simpleId;
  final String nameEnglish;
  final String? nameUrdu;
  final String? description;
  final int classCount;
  final int subjectCount;
  final int bookCount;
  final int studentCount;

  @override
  List<Object?> get props => [
        id,
        simpleId,
        nameEnglish,
        nameUrdu,
        description,
        classCount,
        subjectCount,
        bookCount,
        studentCount,
      ];
}
