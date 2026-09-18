enum ExamAttendanceStatus {
  verified,
  duplicateBlocked,
  flagged,
}

/// Domain model representing a student scanned during an exam or multi-class event session.
class ExamQrAttendanceRecord {
  const ExamQrAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.admissionNo,
    required this.rollNo,
    required this.registeredClass,
    required this.examHall,
    required this.seatNo,
    required this.scannedAt,
    this.status = ExamAttendanceStatus.verified,
    this.isSynced = true,
    this.avatarUrl,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String admissionNo;
  final String rollNo;
  final String registeredClass;
  final String examHall;
  final String seatNo;
  final DateTime scannedAt;
  final ExamAttendanceStatus status;
  final bool isSynced;
  final String? avatarUrl;

  ExamQrAttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? admissionNo,
    String? rollNo,
    String? registeredClass,
    String? examHall,
    String? seatNo,
    DateTime? scannedAt,
    ExamAttendanceStatus? status,
    bool? isSynced,
    String? avatarUrl,
  }) {
    return ExamQrAttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      admissionNo: admissionNo ?? this.admissionNo,
      rollNo: rollNo ?? this.rollNo,
      registeredClass: registeredClass ?? this.registeredClass,
      examHall: examHall ?? this.examHall,
      seatNo: seatNo ?? this.seatNo,
      scannedAt: scannedAt ?? this.scannedAt,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// Institutional student entity for barcode/QR resolution and manual lookup
class StudentExamEntity {
  const StudentExamEntity({
    required this.studentId,
    required this.name,
    required this.admissionNo,
    required this.rollNo,
    required this.registeredClass,
    required this.assignedHall,
    required this.assignedDesk,
    this.avatarUrl,
  });

  final String studentId;
  final String name;
  final String admissionNo;
  final String rollNo;
  final String registeredClass;
  final String assignedHall;
  final String assignedDesk;
  final String? avatarUrl;
}
