import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';

/// DTO Model for Staff Manual Attendance with JSON serialization (< 90 lines).
class StaffManualAttendanceModel extends StaffManualAttendanceEntity {
  const StaffManualAttendanceModel({
    required super.staffId,
    required super.staffCode,
    required super.fullNameEn,
    required super.nameUrdu,
    required super.designation,
    super.department,
    super.photoUrl,
    super.status,
    super.punchInTime,
    super.punchOutTime,
  });

  factory StaffManualAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StaffManualAttendanceModel(
      staffId: json['staffId']?.toString() ?? '',
      staffCode: json['staffCode'] is int
          ? json['staffCode'] as int
          : int.tryParse(json['staffCode']?.toString() ?? '0') ?? 0,
      fullNameEn: json['fullNameEn']?.toString() ?? '',
      nameUrdu: json['nameUrdu']?.toString() ?? '',
      designation: json['designation']?.toString() ?? 'Teacher',
      department: json['department']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
      status: StaffAttendanceStatus.fromKey(json['status']?.toString()),
      punchInTime: json['punchInTime']?.toString(),
      punchOutTime: json['punchOutTime']?.toString(),
    );
  }

  factory StaffManualAttendanceModel.fromEntity(StaffManualAttendanceEntity entity) {
    return StaffManualAttendanceModel(
      staffId: entity.staffId,
      staffCode: entity.staffCode,
      fullNameEn: entity.fullNameEn,
      nameUrdu: entity.nameUrdu,
      designation: entity.designation,
      department: entity.department,
      photoUrl: entity.photoUrl,
      status: entity.status,
      punchInTime: entity.punchInTime,
      punchOutTime: entity.punchOutTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffCode': staffCode,
      'fullNameEn': fullNameEn,
      'nameUrdu': nameUrdu,
      'designation': designation,
      'department': department,
      'photoUrl': photoUrl,
      'status': status.key,
      'punchInTime': punchInTime,
      'punchOutTime': punchOutTime,
    };
  }
}
