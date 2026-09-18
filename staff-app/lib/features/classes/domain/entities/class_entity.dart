import 'package:equatable/equatable.dart';

class ClassEntity extends Equatable {
  const ClassEntity({
    required this.id,
    required this.simpleId,
    required this.courseId,
    required this.courseName,
    required this.nameEnglish,
    this.nameUrdu,
    this.capacity = 50,
    this.studentCount = 0,
    this.subjectCount = 0,
    this.bookCount = 0,
    this.hasFeeStructure = false,
  });

  final String id;
  final int simpleId;
  final String courseId;
  final String courseName;
  final String nameEnglish;
  final String? nameUrdu;
  final int capacity;
  final int studentCount;
  final int subjectCount;
  final int bookCount;
  final bool hasFeeStructure;

  int get occupancyPercent => capacity > 0 ? ((studentCount / capacity) * 100).clamp(0, 100).toInt() : 0;

  @override
  List<Object?> get props => [
        id,
        simpleId,
        courseId,
        courseName,
        nameEnglish,
        nameUrdu,
        capacity,
        studentCount,
        subjectCount,
        bookCount,
        hasFeeStructure,
      ];
}
