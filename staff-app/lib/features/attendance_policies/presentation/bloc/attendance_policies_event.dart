import 'package:equatable/equatable.dart';

abstract class AttendancePoliciesEvent extends Equatable {
  const AttendancePoliciesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendancePoliciesEvent extends AttendancePoliciesEvent {
  const LoadAttendancePoliciesEvent({this.academicYearId});

  final String? academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

class UpdateWeeklyOffDayEvent extends AttendancePoliciesEvent {
  const UpdateWeeklyOffDayEvent(this.day);

  final String day; // 'MONDAY' ... 'SUNDAY'

  @override
  List<Object?> get props => [day];
}

class UpdateMinimumAttendanceEvent extends AttendancePoliciesEvent {
  const UpdateMinimumAttendanceEvent(this.percent);

  final int percent;

  @override
  List<Object?> get props => [percent];
}

class UpdateStudentLeaveQuotaEvent extends AttendancePoliciesEvent {
  const UpdateStudentLeaveQuotaEvent(this.days);

  final int days;

  @override
  List<Object?> get props => [days];
}

class UpdateStaffLeaveQuotaEvent extends AttendancePoliciesEvent {
  const UpdateStaffLeaveQuotaEvent(this.days);

  final int days;

  @override
  List<Object?> get props => [days];
}

class UpdateConsecutiveDropoutDaysEvent extends AttendancePoliciesEvent {
  const UpdateConsecutiveDropoutDaysEvent(this.days);

  final int days;

  @override
  List<Object?> get props => [days];
}

class ResetPoliciesToDefaultEvent extends AttendancePoliciesEvent {
  const ResetPoliciesToDefaultEvent();
}

class SaveAttendancePoliciesEvent extends AttendancePoliciesEvent {
  const SaveAttendancePoliciesEvent();
}
