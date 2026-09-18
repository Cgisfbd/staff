import 'package:flutter/widgets.dart';
import 'package:staff_app/core/l10n/app_strings.dart';

enum AttendanceStatus {
  present,
  absent,
  leave,
}

enum HistoryDayStatus {
  present,
  absent,
  leave,
}

/// Domain entity representing a student in the daily attendance roster
class StudentAttendanceItem {
  const StudentAttendanceItem({
    required this.studentId,
    required this.name,
    this.nameUrdu = '',
    this.nameHindi = '',
    required this.rollNo,
    required this.admissionNo,
    this.avatarUrl,
    required this.lastThreeDays,
    this.status = AttendanceStatus.present,
  });

  final String studentId;
  final String name;
  final String nameUrdu;
  final String nameHindi;
  final String rollNo;
  final String admissionNo;
  final String? avatarUrl;
  final List<HistoryDayStatus> lastThreeDays;
  final AttendanceStatus status;

  /// Returns localized student name based on language/context/RTL
  String localizedName([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'student_$studentId';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      if (nameUrdu.isNotEmpty) return nameUrdu;
    }
    if (langCode == 'hi' && nameHindi.isNotEmpty) {
      return nameHindi;
    }
    return name;
  }

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isLeave => status == AttendanceStatus.leave;

  StudentAttendanceItem copyWith({
    String? studentId,
    String? name,
    String? nameUrdu,
    String? nameHindi,
    String? rollNo,
    String? admissionNo,
    String? avatarUrl,
    List<HistoryDayStatus>? lastThreeDays,
    AttendanceStatus? status,
  }) {
    return StudentAttendanceItem(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      nameHindi: nameHindi ?? this.nameHindi,
      rollNo: rollNo ?? this.rollNo,
      admissionNo: admissionNo ?? this.admissionNo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastThreeDays: lastThreeDays ?? this.lastThreeDays,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAttendanceItem && other.studentId == studentId;

  @override
  int get hashCode => studentId.hashCode;
}
