import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';
import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';
import 'package:staff_app/features/attendance_policies/domain/repositories/attendance_policies_repository.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_event.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_state.dart';

class AttendancePoliciesBloc extends Bloc<AttendancePoliciesEvent, AttendancePoliciesState> {
  AttendancePoliciesBloc({
    required this.attendancePoliciesRepository,
    required this.academicSessionRepository,
  }) : super(AttendancePoliciesState.initial()) {
    on<LoadAttendancePoliciesEvent>(_onLoadAttendancePolicies);
    on<UpdateWeeklyOffDayEvent>(_onUpdateWeeklyOffDay);
    on<UpdateMinimumAttendanceEvent>(_onUpdateMinimumAttendance);
    on<UpdateStudentLeaveQuotaEvent>(_onUpdateStudentLeaveQuota);
    on<UpdateStaffLeaveQuotaEvent>(_onUpdateStaffLeaveQuota);
    on<UpdateConsecutiveDropoutDaysEvent>(_onUpdateConsecutiveDropoutDays);
    on<ResetPoliciesToDefaultEvent>(_onResetPoliciesToDefault);
    on<SaveAttendancePoliciesEvent>(_onSaveAttendancePolicies);
  }

  final AttendancePoliciesRepository attendancePoliciesRepository;
  final AcademicSessionRepository academicSessionRepository;

  Future<void> _onLoadAttendancePolicies(
    LoadAttendancePoliciesEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) async {
    String yearId = event.academicYearId ?? state.academicYearId;
    String? yearName = state.academicYearName;

    if (yearId.isEmpty) {
      yearId = '2071013f-1144-4980-9901-3e51b2f2e487';
      yearName = '1446-1447 AH (2025-2026)';
    }

    try {
      final sessionsResult = await academicSessionRepository
          .getAcademicSessions()
          .timeout(const Duration(seconds: 2));

      sessionsResult.fold(
        (_) {},
        (sessions) {
          if (sessions.isNotEmpty) {
            final active = sessions.firstWhere(
              (s) => s.isActive,
              orElse: () => sessions.first,
            );
            yearId = active.id;
            yearName = active.yearName;
          }
        },
      );
    } catch (_) {}

    final result = await attendancePoliciesRepository.getAttendancePolicies(
      academicYearId: yearId,
    );

    result.fold(
      (failure) {
        final fallback = AttendancePolicy.defaultPolicy(yearId);
        emit(state.copyWith(
          status: AttendancePoliciesStatus.loaded,
          policy: fallback,
          academicYearId: yearId,
          academicYearName: yearName,
          isModified: false,
        ));
      },
      (policy) {
        emit(state.copyWith(
          status: AttendancePoliciesStatus.loaded,
          policy: policy,
          academicYearId: yearId,
          academicYearName: yearName,
          isModified: false,
        ));
      },
    );
  }

  void _onUpdateWeeklyOffDay(
    UpdateWeeklyOffDayEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) {
    final updated = state.policy.copyWith(weeklyOffDay: event.day);
    emit(state.copyWith(policy: updated, isModified: true));
  }

  void _onUpdateMinimumAttendance(
    UpdateMinimumAttendanceEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) {
    final updated = state.policy.copyWith(minimumAttendancePercent: event.percent);
    emit(state.copyWith(policy: updated, isModified: true));
  }

  void _onUpdateStudentLeaveQuota(
    UpdateStudentLeaveQuotaEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) {
    final updated = state.policy.copyWith(annualStudentLeaveQuota: event.days);
    emit(state.copyWith(policy: updated, isModified: true));
  }

  void _onUpdateStaffLeaveQuota(
    UpdateStaffLeaveQuotaEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) {
    final updated = state.policy.copyWith(annualStaffLeaveQuota: event.days);
    emit(state.copyWith(policy: updated, isModified: true));
  }

  void _onUpdateConsecutiveDropoutDays(
    UpdateConsecutiveDropoutDaysEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) {
    final updated = state.policy.copyWith(consecutiveAbsentDropoutDays: event.days);
    emit(state.copyWith(policy: updated, isModified: true));
  }

  void _onResetPoliciesToDefault(
    ResetPoliciesToDefaultEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) {
    final defaultP = AttendancePolicy.defaultPolicy(state.academicYearId);
    emit(state.copyWith(
      policy: defaultP,
      isModified: true,
      successMessage: 'Reset to default criteria. Save to persist.',
    ));
  }

  Future<void> _onSaveAttendancePolicies(
    SaveAttendancePoliciesEvent event,
    Emitter<AttendancePoliciesState> emit,
  ) async {
    emit(state.copyWith(status: AttendancePoliciesStatus.saving));

    final result = await attendancePoliciesRepository.upsertAttendancePolicies(
      academicYearId: state.academicYearId,
      policy: state.policy,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendancePoliciesStatus.error,
        errorMessage: failure.message,
      )),
      (saved) => emit(state.copyWith(
        status: AttendancePoliciesStatus.saved,
        policy: saved,
        isModified: false,
        successMessage: 'Attendance policies & thresholds saved!',
      )),
    );
  }
}
