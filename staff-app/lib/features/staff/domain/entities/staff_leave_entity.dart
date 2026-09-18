import 'package:equatable/equatable.dart';

/// Status of Staff Leave Request
enum StaffLeaveStatus {
  pending,
  approved,
  rejected,
}

/// Category / Nature of Leave
enum StaffLeaveType {
  casual,
  medical,
  urgent,
  academic,
}

extension StaffLeaveTypeX on StaffLeaveType {
  String get label {
    switch (this) {
      case StaffLeaveType.casual:
        return 'Casual Leave (اتفاقی)';
      case StaffLeaveType.medical:
        return 'Medical Leave (طبی)';
      case StaffLeaveType.urgent:
        return 'Urgent Work (ضروری کام)';
      case StaffLeaveType.academic:
        return 'Academic Duty (تعلیمی)';
    }
  }

  String get shortLabel {
    switch (this) {
      case StaffLeaveType.casual:
        return 'Casual';
      case StaffLeaveType.medical:
        return 'Medical';
      case StaffLeaveType.urgent:
        return 'Urgent';
      case StaffLeaveType.academic:
        return 'Academic';
    }
  }
}

/// Domain Entity for a single Staff Leave Request
class StaffLeaveEntity extends Equatable {
  const StaffLeaveEntity({
    required this.id,
    required this.facultyId,
    required this.staffCode,
    required this.teacherName,
    this.avatar = '',
    this.designation = '',
    this.department = '',
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = StaffLeaveStatus.pending,
    required this.appliedAt,
    this.reviewedBy = '',
    this.rejectionReason = '',
  });

  final String id;
  final String facultyId;
  final int staffCode;
  final String teacherName;
  final String avatar;
  final String designation;
  final String department;
  final StaffLeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final StaffLeaveStatus status;
  final DateTime appliedAt;
  final String reviewedBy;
  final String rejectionReason;

  StaffLeaveEntity copyWith({
    String? id,
    String? facultyId,
    int? staffCode,
    String? teacherName,
    String? avatar,
    String? designation,
    String? department,
    StaffLeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? reason,
    StaffLeaveStatus? status,
    DateTime? appliedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return StaffLeaveEntity(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      staffCode: staffCode ?? this.staffCode,
      teacherName: teacherName ?? this.teacherName,
      avatar: avatar ?? this.avatar,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        facultyId,
        staffCode,
        teacherName,
        avatar,
        designation,
        department,
        leaveType,
        startDate,
        endDate,
        totalDays,
        reason,
        status,
        appliedAt,
        reviewedBy,
        rejectionReason,
      ];
}

/// Domain Entity for Staff Leaves KPI Summary Deck
class StaffLeaveStatsEntity extends Equatable {
  const StaffLeaveStatsEntity({
    required this.pendingCount,
    required this.approvedTodayCount,
    required this.totalThisMonth,
    required this.totalStaffOnLeave,
  });

  final int pendingCount;
  final int approvedTodayCount;
  final int totalThisMonth;
  final int totalStaffOnLeave;

  @override
  List<Object?> get props => [
        pendingCount,
        approvedTodayCount,
        totalThisMonth,
        totalStaffOnLeave,
      ];
}
