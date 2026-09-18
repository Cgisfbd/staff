import 'package:equatable/equatable.dart';

class SubjectMarkDetail extends Equatable {
  const SubjectMarkDetail({
    required this.subjectName,
    required this.subjectNameUrdu,
    required this.maxMarks,
    required this.minMarks,
    this.obtainedMarks,
    this.isAbsent = false,
    required this.grade,
  });

  final String subjectName;
  final String subjectNameUrdu;
  final int maxMarks;
  final int minMarks;
  final int? obtainedMarks;
  final bool isAbsent;
  final String grade;

  @override
  List<Object?> get props => [
        subjectName,
        subjectNameUrdu,
        maxMarks,
        minMarks,
        obtainedMarks,
        isAbsent,
        grade,
      ];
}

class StudentResultModel extends Equatable {
  const StudentResultModel({
    required this.studentId,
    required this.rollNo,
    required this.admissionNo,
    required this.nameEnglish,
    required this.nameUrdu,
    required this.fatherNameEnglish,
    required this.fatherNameUrdu,
    required this.className,
    required this.courseName,
    required this.academicSession,
    required this.subjects,
    required this.totalMax,
    required this.totalObtained,
    required this.percentage,
    required this.overallGrade,
    required this.division,
    required this.resultStatus,
    this.rank,
  });

  final String studentId;
  final String rollNo;
  final String admissionNo;
  final String nameEnglish;
  final String nameUrdu;
  final String fatherNameEnglish;
  final String fatherNameUrdu;
  final String className;
  final String courseName;
  final String academicSession;
  final List<SubjectMarkDetail> subjects;
  final int totalMax;
  final int totalObtained;
  final double percentage;
  final String overallGrade;
  final String division;
  final String resultStatus; // 'PASSED' | 'FAILED' | 'ABSENT'
  final int? rank;

  bool get isPassed => resultStatus == 'PASSED';
  bool get isAbsent => resultStatus == 'ABSENT';

  @override
  List<Object?> get props => [
        studentId,
        rollNo,
        admissionNo,
        nameEnglish,
        nameUrdu,
        fatherNameEnglish,
        fatherNameUrdu,
        className,
        courseName,
        academicSession,
        subjects,
        totalMax,
        totalObtained,
        percentage,
        overallGrade,
        division,
        resultStatus,
        rank,
      ];
}
