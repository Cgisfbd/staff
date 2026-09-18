import 'package:equatable/equatable.dart';

/// Clean Architecture Domain Entity representing a Textbook/Kitab
class BookEntity extends Equatable {
  const BookEntity({
    required this.id,
    required this.simpleId,
    required this.subjectId,
    this.subjectName,
    this.className,
    this.courseName,
    required this.nameEnglish,
    required this.nameUrdu,
    this.category = 'DEENI',
    this.term = 'FULL_YEAR',
    this.maxMarks = 100,
    this.passMarks = 33,
    this.theoryMarks = 100,
    this.practicalMarks = 0,
  });

  final String id;
  final int simpleId;
  final String subjectId;
  final String? subjectName;
  final String? className;
  final String? courseName;
  final String nameEnglish;
  final String nameUrdu;
  final String category; // 'DEENI', 'ASRI', 'OTHER'
  final String term; // 'FULL_YEAR', 'TERM_1', 'TERM_2'
  final int maxMarks;
  final int passMarks;
  final int theoryMarks;
  final int practicalMarks;

  @override
  List<Object?> get props => [
        id,
        simpleId,
        subjectId,
        subjectName,
        className,
        courseName,
        nameEnglish,
        nameUrdu,
        category,
        term,
        maxMarks,
        passMarks,
        theoryMarks,
        practicalMarks,
      ];
}
