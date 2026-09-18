import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

/// Data Model for Staff Leave Request
class StaffLeaveModel extends StaffLeaveEntity {
  const StaffLeaveModel({
    required super.id,
    required super.facultyId,
    required super.staffCode,
    required super.teacherName,
    super.avatar = '',
    super.designation = '',
    super.department = '',
    required super.leaveType,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.reason,
    super.status = StaffLeaveStatus.pending,
    required super.appliedAt,
    super.reviewedBy = '',
    super.rejectionReason = '',
  });

  factory StaffLeaveModel.fromJson(Map<String, dynamic> json) {
    return StaffLeaveModel(
      id: json['id']?.toString() ?? '',
      facultyId: json['facultyId']?.toString() ?? '',
      staffCode: (json['staffCode'] as num?)?.toInt() ?? 0,
      teacherName: json['teacherName']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      leaveType: _parseLeaveType(json['leaveType']?.toString()),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 1,
      reason: json['reason']?.toString() ?? '',
      status: _parseLeaveStatus(json['status']?.toString()),
      appliedAt: DateTime.tryParse(json['appliedAt']?.toString() ?? '') ?? DateTime.now(),
      reviewedBy: json['reviewedBy']?.toString() ?? '',
      rejectionReason: json['rejectionReason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facultyId': facultyId,
      'staffCode': staffCode,
      'teacherName': teacherName,
      'avatar': avatar,
      'designation': designation,
      'department': department,
      'leaveType': leaveType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }

  static StaffLeaveType _parseLeaveType(String? val) {
    switch (val?.toLowerCase()) {
      case 'medical':
        return StaffLeaveType.medical;
      case 'urgent':
        return StaffLeaveType.urgent;
      case 'academic':
        return StaffLeaveType.academic;
      case 'casual':
      default:
        return StaffLeaveType.casual;
    }
  }

  static StaffLeaveStatus _parseLeaveStatus(String? val) {
    switch (val?.toLowerCase()) {
      case 'approved':
        return StaffLeaveStatus.approved;
      case 'rejected':
        return StaffLeaveStatus.rejected;
      case 'pending':
      default:
        return StaffLeaveStatus.pending;
    }
  }

  /// Initial Realistic Institutional Seed Data
  static final List<StaffLeaveModel> seedLeaves = [
    StaffLeaveModel(
      id: 'leave-101',
      facultyId: 'fac-101-mawlana-abdur-rahman',
      staffCode: 101,
      teacherName: 'Mawlana Abdur Rahman Qasmi',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      designation: 'Senior Lecturer (Hadith & Fiqh)',
      department: 'Shu’ba-e-Aalimiyat',
      leaveType: StaffLeaveType.urgent,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      totalDays: 2,
      reason: 'Family wedding event in native village, urgent personal commitment.',
      status: StaffLeaveStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    StaffLeaveModel(
      id: 'leave-102',
      facultyId: 'fac-102-qari-mohammad-salman',
      staffCode: 102,
      teacherName: 'Qari Mohammad Salman',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      designation: 'Head Qari / Nazim-e-Hifz',
      department: 'Shu’ba-e-Hifz & Tajweed',
      leaveType: StaffLeaveType.medical,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      totalDays: 2,
      reason: 'Severe fever and sore throat, doctor advised clinical rest for 48 hours.',
      status: StaffLeaveStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      reviewedBy: 'Muhtamim / Principal',
    ),
    StaffLeaveModel(
      id: 'leave-103',
      facultyId: 'fac-103-mufti-tariq-jameel',
      staffCode: 103,
      teacherName: 'Mufti Tariq Jameel Thanvi',
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      designation: 'Mufti / Fiqh Researcher',
      department: 'Dar-ul-Ifta & Fiqh',
      leaveType: StaffLeaveType.academic,
      startDate: DateTime.now().add(const Duration(days: 4)),
      endDate: DateTime.now().add(const Duration(days: 6)),
      totalDays: 3,
      reason: 'Attending National Fiqh Seminar and Shariah Council deliberations in New Delhi.',
      status: StaffLeaveStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      reviewedBy: 'Academic Council',
    ),
    StaffLeaveModel(
      id: 'leave-104',
      facultyId: 'fac-104-mawlana-zubair-ahmad',
      staffCode: 104,
      teacherName: 'Mawlana Zubair Ahmad Nadwi',
      avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      designation: 'Senior Arabic Teacher',
      department: 'Shu’ba-e-Adab-e-Arabi',
      leaveType: StaffLeaveType.casual,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 4)),
      totalDays: 2,
      reason: 'Personal home renovation work requiring continuous presence.',
      status: StaffLeaveStatus.rejected,
      appliedAt: DateTime.now().subtract(const Duration(days: 6)),
      reviewedBy: 'Vice Principal',
      rejectionReason: 'Exams revision ongoing, non-urgent leaves currently restricted.',
    ),
    StaffLeaveModel(
      id: 'leave-105',
      facultyId: 'fac-101-mawlana-abdur-rahman',
      staffCode: 101,
      teacherName: 'Mawlana Abdur Rahman Qasmi',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      designation: 'Senior Lecturer (Hadith & Fiqh)',
      department: 'Shu’ba-e-Aalimiyat',
      leaveType: StaffLeaveType.medical,
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      endDate: DateTime.now().subtract(const Duration(days: 13)),
      totalDays: 2,
      reason: 'Acute fever and viral infection, medical rest prescribed.',
      status: StaffLeaveStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 15)),
      reviewedBy: 'Muhtamim / Principal',
    ),
    StaffLeaveModel(
      id: 'leave-106',
      facultyId: 'fac-101-mawlana-abdur-rahman',
      staffCode: 101,
      teacherName: 'Mawlana Abdur Rahman Qasmi',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      designation: 'Senior Lecturer (Hadith & Fiqh)',
      department: 'Shu’ba-e-Aalimiyat',
      leaveType: StaffLeaveType.casual,
      startDate: DateTime.now().subtract(const Duration(days: 28)),
      endDate: DateTime.now().subtract(const Duration(days: 27)),
      totalDays: 2,
      reason: 'Attending relative domestic function out of station.',
      status: StaffLeaveStatus.rejected,
      appliedAt: DateTime.now().subtract(const Duration(days: 29)),
      reviewedBy: 'Vice Principal',
      rejectionReason: 'Examination revision period. All faculty non-emergency leave is suspended by Academic Council.',
    ),
  ];
}

/// Data Model for Staff Leave Stats KPI Deck
class StaffLeaveStatsModel extends StaffLeaveStatsEntity {
  const StaffLeaveStatsModel({
    required super.pendingCount,
    required super.approvedTodayCount,
    required super.totalThisMonth,
    required super.totalStaffOnLeave,
  });

  factory StaffLeaveStatsModel.fromLeaves(List<StaffLeaveModel> leaves) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int pending = 0;
    int approvedToday = 0;
    int totalMonth = 0;
    int onLeaveNow = 0;

    for (final l in leaves) {
      if (l.status == StaffLeaveStatus.pending) {
        pending++;
      } else if (l.status == StaffLeaveStatus.approved) {
        totalMonth++;
        final start = DateTime(l.startDate.year, l.startDate.month, l.startDate.day);
        final end = DateTime(l.endDate.year, l.endDate.month, l.endDate.day);
        if ((today.isAtSameMomentAs(start) || today.isAfter(start)) &&
            (today.isAtSameMomentAs(end) || today.isBefore(end))) {
          approvedToday++;
          onLeaveNow++;
        }
      }
    }

    return StaffLeaveStatsModel(
      pendingCount: pending,
      approvedTodayCount: approvedToday,
      totalThisMonth: totalMonth,
      totalStaffOnLeave: onLeaveNow,
    );
  }
}
