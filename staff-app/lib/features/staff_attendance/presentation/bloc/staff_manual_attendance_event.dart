import 'package:equatable/equatable.dart';
import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';

abstract class StaffManualAttendanceEvent extends Equatable {
  const StaffManualAttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffAttendanceEvent extends StaffManualAttendanceEvent {
  const LoadStaffAttendanceEvent({required this.date});

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class ChangeAttendanceDateEvent extends StaffManualAttendanceEvent {
  const ChangeAttendanceDateEvent({required this.date});

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class UpdateStaffSearchQueryEvent extends StaffManualAttendanceEvent {
  const UpdateStaffSearchQueryEvent({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class UpdateStaffStatusEvent extends StaffManualAttendanceEvent {
  const UpdateStaffStatusEvent({
    required this.staffId,
    required this.status,
  });

  final String staffId;
  final StaffAttendanceStatus status;

  @override
  List<Object?> get props => [staffId, status];
}

class UpdateStaffPunchTimeEvent extends StaffManualAttendanceEvent {
  const UpdateStaffPunchTimeEvent({
    required this.staffId,
    this.punchInTime,
    this.punchOutTime,
    this.clearPunchIn = false,
    this.clearPunchOut = false,
  });

  final String staffId;
  final String? punchInTime;
  final String? punchOutTime;
  final bool clearPunchIn;
  final bool clearPunchOut;

  @override
  List<Object?> get props => [
        staffId,
        punchInTime,
        punchOutTime,
        clearPunchIn,
        clearPunchOut,
      ];
}

class MarkAllStaffPresentEvent extends StaffManualAttendanceEvent {
  const MarkAllStaffPresentEvent();
}

class SaveStaffAttendanceBatchEvent extends StaffManualAttendanceEvent {
  const SaveStaffAttendanceBatchEvent();
}
