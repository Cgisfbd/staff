import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';
import 'package:staff_app/features/staff_attendance/domain/usecases/get_staff_attendance_list_usecase.dart';
import 'package:staff_app/features/staff_attendance/domain/usecases/save_staff_attendance_batch_usecase.dart';
import 'package:staff_app/features/staff_attendance/presentation/bloc/staff_manual_attendance_event.dart';
import 'package:staff_app/features/staff_attendance/presentation/bloc/staff_manual_attendance_state.dart';

/// Business Logic Component for Super Admin Staff Manual Attendance (< 160 lines).
class StaffManualAttendanceBloc
    extends Bloc<StaffManualAttendanceEvent, StaffManualAttendanceState> {
  StaffManualAttendanceBloc({
    required this.getStaffAttendanceListUseCase,
    required this.saveStaffAttendanceBatchUseCase,
  }) : super(StaffManualAttendanceState(selectedDate: DateTime.now())) {
    on<LoadStaffAttendanceEvent>(_onLoadStaffAttendance);
    on<ChangeAttendanceDateEvent>(_onChangeAttendanceDate);
    on<UpdateStaffSearchQueryEvent>(_onUpdateSearchQuery);
    on<UpdateStaffStatusEvent>(_onUpdateStaffStatus);
    on<UpdateStaffPunchTimeEvent>(_onUpdateStaffPunchTime);
    on<MarkAllStaffPresentEvent>(_onMarkAllPresent);
    on<SaveStaffAttendanceBatchEvent>(_onSaveStaffAttendanceBatch);
  }

  final GetStaffAttendanceListUseCase getStaffAttendanceListUseCase;
  final SaveStaffAttendanceBatchUseCase saveStaffAttendanceBatchUseCase;

  Future<void> _onLoadStaffAttendance(
    LoadStaffAttendanceEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) async {
    emit(state.copyWith(
      status: StaffAttendanceStateStatus.loading,
      selectedDate: event.date,
      clearMessages: true,
    ));

    try {
      final records = await getStaffAttendanceListUseCase(date: event.date);
      emit(state.copyWith(
        status: StaffAttendanceStateStatus.loaded,
        records: records,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffAttendanceStateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeAttendanceDate(
    ChangeAttendanceDateEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) async {
    add(LoadStaffAttendanceEvent(date: event.date));
  }

  void _onUpdateSearchQuery(
    UpdateStaffSearchQueryEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onUpdateStaffStatus(
    UpdateStaffStatusEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) {
    final updatedRecords = state.records.map((record) {
      if (record.staffId == event.staffId) {
        return record.copyWith(status: event.status);
      }
      return record;
    }).toList();

    emit(state.copyWith(records: updatedRecords));
  }

  void _onUpdateStaffPunchTime(
    UpdateStaffPunchTimeEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) {
    final updatedRecords = state.records.map((record) {
      if (record.staffId == event.staffId) {
        // Automatically make sure status is present if punching in
        final newStatus = (event.punchInTime != null && !event.clearPunchIn)
            ? StaffAttendanceStatus.present
            : record.status;

        return record.copyWith(
          status: newStatus,
          punchInTime: event.punchInTime,
          punchOutTime: event.punchOutTime,
          clearPunchIn: event.clearPunchIn,
          clearPunchOut: event.clearPunchOut,
        );
      }
      return record;
    }).toList();

    emit(state.copyWith(records: updatedRecords));
  }

  void _onMarkAllPresent(
    MarkAllStaffPresentEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) {
    final updatedRecords = state.records.map((record) {
      return record.copyWith(status: StaffAttendanceStatus.present);
    }).toList();

    emit(state.copyWith(records: updatedRecords));
  }

  Future<void> _onSaveStaffAttendanceBatch(
    SaveStaffAttendanceBatchEvent event,
    Emitter<StaffManualAttendanceState> emit,
  ) async {
    if (state.records.isEmpty) return;

    emit(state.copyWith(
      status: StaffAttendanceStateStatus.saving,
      clearMessages: true,
    ));

    try {
      await saveStaffAttendanceBatchUseCase(
        date: state.selectedDate,
        records: state.records,
      );

      emit(state.copyWith(
        status: StaffAttendanceStateStatus.success,
        successMessage: 'Staff attendance saved successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffAttendanceStateStatus.failure,
        errorMessage: 'Failed saving attendance: $e',
      ));
    }
  }
}
