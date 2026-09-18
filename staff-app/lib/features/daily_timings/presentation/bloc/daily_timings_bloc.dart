import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';
import 'package:staff_app/features/daily_timings/domain/repositories/daily_timings_repository.dart';
import 'package:staff_app/features/daily_timings/domain/services/schedule_calculator.dart';
import 'package:staff_app/features/daily_timings/presentation/bloc/daily_timings_event.dart';
import 'package:staff_app/features/daily_timings/presentation/bloc/daily_timings_state.dart';

class DailyTimingsBloc extends Bloc<DailyTimingsEvent, DailyTimingsState> {
  DailyTimingsBloc({
    required this.dailyTimingsRepository,
    required this.academicSessionRepository,
  }) : super(DailyTimingsState.initial()) {
    on<LoadScheduleTimingsEvent>(_onLoadScheduleTimings);
    on<UpdateAssemblyTimeEvent>(_onUpdateAssemblyTime);
    on<UpdateStartTimeEvent>(_onUpdateStartTime);
    on<UpdateLunchSlotEvent>(_onUpdateLunchSlot);
    on<UpdateLunchDurationEvent>(_onUpdateLunchDuration);
    on<UpdatePeriodDurationEvent>(_onUpdatePeriodDuration);
    on<ApplyPresetEvent>(_onApplyPreset);
    on<ResetTimingsEvent>(_onResetTimings);
    on<SaveScheduleTimingsEvent>(_onSaveScheduleTimings);
  }

  final DailyTimingsRepository dailyTimingsRepository;
  final AcademicSessionRepository academicSessionRepository;

  Future<void> _onLoadScheduleTimings(
    LoadScheduleTimingsEvent event,
    Emitter<DailyTimingsState> emit,
  ) async {
    String yearId = event.academicYearId ?? state.academicYearId;
    String? yearName = state.academicYearName;

    if (yearId.isEmpty) {
      yearId = 'session-2024-2025-uuid';
      yearName = 'Academic Session 2024–2025';
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

    try {
      final result = await dailyTimingsRepository
          .getScheduleTimings(academicYearId: yearId)
          .timeout(const Duration(seconds: 3));

      result.fold(
        (_) {
          // If server fails, keep loaded with current timings
          emit(state.copyWith(
            status: DailyTimingsStatus.loaded,
            academicYearId: yearId,
            academicYearName: yearName,
          ));
        },
        (timings) {
          final computation = ScheduleCalculator.computeSchedule(
            startTime: timings.startTime,
            periodDurations: timings.periodDurations,
            lunchDurationMinutes: timings.lunchDurationMinutes,
            lunchAfterPeriod: timings.lunchAfterPeriod,
          );

          emit(
            state.copyWith(
              status: DailyTimingsStatus.loaded,
              academicYearId: yearId,
              academicYearName: yearName,
              timings: timings,
              computation: computation,
            ),
          );
        },
      );
    } catch (_) {
      emit(state.copyWith(
        status: DailyTimingsStatus.loaded,
        academicYearId: yearId,
        academicYearName: yearName,
      ));
    }
  }

  void _onUpdateAssemblyTime(
    UpdateAssemblyTimeEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    final updated = state.timings.copyWith(assemblyTime: event.assemblyTime);
    emit(state.copyWith(timings: updated, isSavedRecently: false));
  }

  void _onUpdateStartTime(
    UpdateStartTimeEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    final updated = state.timings.copyWith(startTime: event.startTime);
    final comp = ScheduleCalculator.computeSchedule(
      startTime: event.startTime,
      periodDurations: updated.periodDurations,
      lunchDurationMinutes: updated.lunchDurationMinutes,
      lunchAfterPeriod: updated.lunchAfterPeriod,
    );
    emit(state.copyWith(timings: updated, computation: comp, isSavedRecently: false));
  }

  void _onUpdateLunchSlot(
    UpdateLunchSlotEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    final updated = state.timings.copyWith(lunchAfterPeriod: event.lunchAfterPeriod);
    final comp = ScheduleCalculator.computeSchedule(
      startTime: updated.startTime,
      periodDurations: updated.periodDurations,
      lunchDurationMinutes: updated.lunchDurationMinutes,
      lunchAfterPeriod: event.lunchAfterPeriod,
    );
    emit(state.copyWith(timings: updated, computation: comp, isSavedRecently: false));
  }

  void _onUpdateLunchDuration(
    UpdateLunchDurationEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    final updated = state.timings.copyWith(lunchDurationMinutes: event.lunchDurationMinutes);
    final comp = ScheduleCalculator.computeSchedule(
      startTime: updated.startTime,
      periodDurations: updated.periodDurations,
      lunchDurationMinutes: event.lunchDurationMinutes,
      lunchAfterPeriod: updated.lunchAfterPeriod,
    );
    emit(state.copyWith(timings: updated, computation: comp, isSavedRecently: false));
  }

  void _onUpdatePeriodDuration(
    UpdatePeriodDurationEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    final newDurations = List<int>.from(state.timings.periodDurations);
    if (event.index >= 0 && event.index < newDurations.length) {
      newDurations[event.index] = event.durationMinutes;
    }
    final updated = state.timings.copyWith(periodDurations: newDurations);
    final comp = ScheduleCalculator.computeSchedule(
      startTime: updated.startTime,
      periodDurations: newDurations,
      lunchDurationMinutes: updated.lunchDurationMinutes,
      lunchAfterPeriod: updated.lunchAfterPeriod,
    );
    emit(state.copyWith(timings: updated, computation: comp, isSavedRecently: false));
  }

  void _onApplyPreset(
    ApplyPresetEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    const defaultDurations = [40, 40, 40, 40, 40, 40, 40, 35];
    final lDur = event.lunchDuration ?? 15;
    final lAfter = event.lunchAfterPeriod ?? 4;

    final updated = state.timings.copyWith(
      assemblyTime: event.assembly,
      startTime: event.start,
      lunchDurationMinutes: lDur,
      lunchAfterPeriod: lAfter,
      periodDurations: defaultDurations,
    );

    final comp = ScheduleCalculator.computeSchedule(
      startTime: event.start,
      periodDurations: defaultDurations,
      lunchDurationMinutes: lDur,
      lunchAfterPeriod: lAfter,
    );

    emit(state.copyWith(timings: updated, computation: comp, isSavedRecently: false));
  }

  void _onResetTimings(
    ResetTimingsEvent event,
    Emitter<DailyTimingsState> emit,
  ) {
    const defaultDurations = [40, 40, 40, 40, 40, 40, 40, 35];
    final updated = state.timings.copyWith(
      assemblyTime: '07:45',
      startTime: '08:00',
      lunchDurationMinutes: 15,
      lunchAfterPeriod: 4,
      periodDurations: defaultDurations,
    );

    final comp = ScheduleCalculator.computeSchedule(
      startTime: '08:00',
      periodDurations: defaultDurations,
      lunchDurationMinutes: 15,
      lunchAfterPeriod: 4,
    );

    emit(state.copyWith(timings: updated, computation: comp, isSavedRecently: false));
  }

  Future<void> _onSaveScheduleTimings(
    SaveScheduleTimingsEvent event,
    Emitter<DailyTimingsState> emit,
  ) async {
    final yearId = state.academicYearId;
    if (yearId.isEmpty) {
      emit(state.copyWith(errorMessage: 'No active academic year found to save schedule.'));
      return;
    }

    final assemblyMins = ScheduleCalculator.timeToMinutes(state.timings.assemblyTime);
    final startMins = ScheduleCalculator.timeToMinutes(state.timings.startTime);
    if (assemblyMins >= startMins) {
      emit(state.copyWith(errorMessage: 'Assembly time must be before class start time.'));
      return;
    }

    emit(state.copyWith(status: DailyTimingsStatus.saving, errorMessage: null));

    final timingsToPersist = state.timings.copyWith(
      lunchStart: state.computation.lunchStart,
      lunchEnd: state.computation.lunchEnd,
      endTime: state.computation.endTime,
    );

    final result = await dailyTimingsRepository.upsertScheduleTimings(
      academicYearId: yearId,
      timings: timingsToPersist,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: DailyTimingsStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (savedTimings) {
        emit(
          state.copyWith(
            status: DailyTimingsStatus.saved,
            timings: savedTimings,
            isSavedRecently: true,
          ),
        );
      },
    );
  }
}
