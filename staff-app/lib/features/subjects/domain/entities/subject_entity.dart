import 'package:equatable/equatable.dart';

/// Clean Architecture Domain Entity representing an academic Subject/Mawdoo
class SubjectEntity extends Equatable {
  const SubjectEntity({
    required this.id,
    required this.simpleId,
    required this.classId,
    required this.className,
    this.courseId,
    this.courseName,
    required this.nameEnglish,
    required this.nameUrdu,
    this.bookCount = 0,
  });

  final String id;
  final int simpleId;
  final String classId;
  final String className;
  final String? courseId;
  final String? courseName;
  final String nameEnglish;
  final String nameUrdu;
  final int bookCount;

  @override
  List<Object?> get props => [
        id,
        simpleId,
        classId,
        className,
        courseId,
        courseName,
        nameEnglish,
        nameUrdu,
        bookCount,
      ];
}
