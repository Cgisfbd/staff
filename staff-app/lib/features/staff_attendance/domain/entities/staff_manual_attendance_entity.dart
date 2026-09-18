import 'package:equatable/equatable.dart';

/// Clean Attendance status enum for Staff Attendance
enum StaffAttendanceStatus {
  present,
  absent,
  leave;

  String get key {
    switch (this) {
      case StaffAttendanceStatus.present:
        return 'PRESENT';
      case StaffAttendanceStatus.absent:
        return 'ABSENT';
      case StaffAttendanceStatus.leave:
        return 'LEAVE';
    }
  }

  static StaffAttendanceStatus fromKey(String? key) {
    if (key == null) return StaffAttendanceStatus.present;
    switch (key.toUpperCase()) {
      case 'ABSENT':
        return StaffAttendanceStatus.absent;
      case 'LEAVE':
        return StaffAttendanceStatus.leave;
      case 'PRESENT':
      default:
        return StaffAttendanceStatus.present;
    }
  }
}

/// Clean Domain Entity for Super Admin Staff Manual Attendance and Punch Record (< 80 lines).
class StaffManualAttendanceEntity extends Equatable {
  const StaffManualAttendanceEntity({
    required this.staffId,
    required this.staffCode,
    required this.fullNameEn,
    required this.nameUrdu,
    required this.designation,
    this.department = '',
    this.photoUrl,
    this.status = StaffAttendanceStatus.present,
    this.punchInTime,
    this.punchOutTime,
  });

  final String staffId;
  final int staffCode;
  final String fullNameEn;
  final String nameUrdu;
  final String designation;
  final String department;
  final String? photoUrl;
  final StaffAttendanceStatus status;
  final String? punchInTime;
  final String? punchOutTime;

  bool get isPunchedIn => punchInTime != null && punchInTime!.isNotEmpty;
  bool get isPunchedOut => punchOutTime != null && punchOutTime!.isNotEmpty;
  bool get isPresent => status == StaffAttendanceStatus.present;
  bool get isAbsent => status == StaffAttendanceStatus.absent;
  bool get isLeave => status == StaffAttendanceStatus.leave;

  StaffManualAttendanceEntity copyWith({
    String? staffId,
    int? staffCode,
    String? fullNameEn,
    String? nameUrdu,
    String? designation,
    String? department,
    String? photoUrl,
    StaffAttendanceStatus? status,
    String? punchInTime,
    String? punchOutTime,
    bool clearPunchIn = false,
    bool clearPunchOut = false,
  }) {
    return StaffManualAttendanceEntity(
      staffId: staffId ?? this.staffId,
      staffCode: staffCode ?? this.staffCode,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      punchInTime: clearPunchIn ? null : (punchInTime ?? this.punchInTime),
      punchOutTime: clearPunchOut ? null : (punchOutTime ?? this.punchOutTime),
    );
  }

  @override
  List<Object?> get props => [
        staffId,
        staffCode,
        fullNameEn,
        nameUrdu,
        designation,
        department,
        photoUrl,
        status,
        punchInTime,
        punchOutTime,
      ];
}
