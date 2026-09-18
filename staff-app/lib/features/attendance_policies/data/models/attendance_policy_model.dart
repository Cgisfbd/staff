import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';

class AttendancePolicyModel extends AttendancePolicy {
  const AttendancePolicyModel({
    required super.id,
    required super.academicYearId,
    required super.minimumAttendancePercent,
    required super.annualStudentLeaveQuota,
    required super.annualStaffLeaveQuota,
    required super.consecutiveAbsentDropoutDays,
    required super.weeklyOffDay,
    super.createdAt,
    super.updatedAt,
  });

  factory AttendancePolicyModel.fromJson(Map<String, dynamic> json, {String? fallbackYearId}) {
    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    DateTime? updated;
    if (json['updatedAt'] != null) {
      updated = DateTime.tryParse(json['updatedAt'].toString());
    }

    return AttendancePolicyModel(
      id: json['id']?.toString() ?? '',
      academicYearId: json['academicYearId']?.toString() ?? fallbackYearId ?? '',
      minimumAttendancePercent: (json['minimumAttendancePercent'] as num?)?.toInt() ?? 75,
      annualStudentLeaveQuota: (json['annualStudentLeaveQuota'] as num?)?.toInt() ?? 14,
      annualStaffLeaveQuota: (json['annualStaffLeaveQuota'] as num?)?.toInt() ?? 14,
      consecutiveAbsentDropoutDays: (json['consecutiveAbsentDropoutDays'] as num?)?.toInt() ?? 15,
      weeklyOffDay: json['weeklyOffDay']?.toString() ?? 'FRIDAY',
      createdAt: created,
      updatedAt: updated,
    );
  }

  factory AttendancePolicyModel.fromEntity(AttendancePolicy entity) {
    return AttendancePolicyModel(
      id: entity.id,
      academicYearId: entity.academicYearId,
      minimumAttendancePercent: entity.minimumAttendancePercent,
      annualStudentLeaveQuota: entity.annualStudentLeaveQuota,
      annualStaffLeaveQuota: entity.annualStaffLeaveQuota,
      consecutiveAbsentDropoutDays: entity.consecutiveAbsentDropoutDays,
      weeklyOffDay: entity.weeklyOffDay,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumAttendancePercent': minimumAttendancePercent,
      'annualStudentLeaveQuota': annualStudentLeaveQuota,
      'annualStaffLeaveQuota': annualStaffLeaveQuota,
      'consecutiveAbsentDropoutDays': consecutiveAbsentDropoutDays,
      'weeklyOffDay': weeklyOffDay,
    };
  }
}
