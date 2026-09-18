/// Immutable Domain Entity representing a student's marks row in evaluation
class StudentMarksRow {
  const StudentMarksRow({
    required this.studentId,
    required this.rollNo,
    required this.name,
    required this.admissionNo,
    required this.registeredClass,
    required this.isAbsent,
    this.obtainedMarks,
    this.maxMarks = 100,
    this.statusRemarks,
  });

  final String studentId;
  final String rollNo;
  final String name;
  final String admissionNo;
  final String registeredClass;
  final bool isAbsent; // If true, marks input is strictly disabled
  final int? obtainedMarks;
  final int maxMarks;
  final String? statusRemarks;

  bool get isEvaluated => !isAbsent && obtainedMarks != null;

  StudentMarksRow copyWith({
    String? studentId,
    String? rollNo,
    String? name,
    String? admissionNo,
    String? registeredClass,
    bool? isAbsent,
    int? obtainedMarks,
    int? maxMarks,
    String? statusRemarks,
  }) {
    return StudentMarksRow(
      studentId: studentId ?? this.studentId,
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      admissionNo: admissionNo ?? this.admissionNo,
      registeredClass: registeredClass ?? this.registeredClass,
      isAbsent: isAbsent ?? this.isAbsent,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      maxMarks: maxMarks ?? this.maxMarks,
      statusRemarks: statusRemarks ?? this.statusRemarks,
    );
  }
}
