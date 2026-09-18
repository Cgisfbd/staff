enum StaffAttendanceStatus {
  present,
  absent,
  leave,
  holiday,
}

/// Data model representing a staff member's daily attendance log record.
class StaffAttendanceRecord {
  const StaffAttendanceRecord({
    required this.id,
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.workingHours,
    this.leaveType,
    this.notes,
  });

  final String id;
  final DateTime date;
  final StaffAttendanceStatus status;
  final String? inTime;
  final String? outTime;
  final String? workingHours;
  final String? leaveType;
  final String? notes;
}
