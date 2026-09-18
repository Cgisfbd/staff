import 'package:equatable/equatable.dart';

class AttendancePolicy extends Equatable {
  const AttendancePolicy({
    required this.id,
    required this.academicYearId,
    required this.minimumAttendancePercent,
    required this.annualStudentLeaveQuota,
    required this.annualStaffLeaveQuota,
    required this.consecutiveAbsentDropoutDays,
    required this.weeklyOffDay,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String academicYearId;
  final int minimumAttendancePercent;
  final int annualStudentLeaveQuota;
  final int annualStaffLeaveQuota;
  final int consecutiveAbsentDropoutDays;
  final String weeklyOffDay; // 'MONDAY' ... 'SUNDAY'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static AttendancePolicy defaultPolicy(String academicYearId) {
    return AttendancePolicy(
      id: 'default-$academicYearId',
      academicYearId: academicYearId,
      minimumAttendancePercent: 75,
      annualStudentLeaveQuota: 14,
      annualStaffLeaveQuota: 14,
      consecutiveAbsentDropoutDays: 15,
      weeklyOffDay: 'FRIDAY',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AttendancePolicy copyWith({
    String? id,
    String? academicYearId,
    int? minimumAttendancePercent,
    int? annualStudentLeaveQuota,
    int? annualStaffLeaveQuota,
    int? consecutiveAbsentDropoutDays,
    String? weeklyOffDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendancePolicy(
      id: id ?? this.id,
      academicYearId: academicYearId ?? this.academicYearId,
      minimumAttendancePercent: minimumAttendancePercent ?? this.minimumAttendancePercent,
      annualStudentLeaveQuota: annualStudentLeaveQuota ?? this.annualStudentLeaveQuota,
      annualStaffLeaveQuota: annualStaffLeaveQuota ?? this.annualStaffLeaveQuota,
      consecutiveAbsentDropoutDays: consecutiveAbsentDropoutDays ?? this.consecutiveAbsentDropoutDays,
      weeklyOffDay: weeklyOffDay ?? this.weeklyOffDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        academicYearId,
        minimumAttendancePercent,
        annualStudentLeaveQuota,
        annualStaffLeaveQuota,
        consecutiveAbsentDropoutDays,
        weeklyOffDay,
        createdAt,
        updatedAt,
      ];
}
