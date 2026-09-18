import 'package:equatable/equatable.dart';
import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';
import 'package:staff_app/features/daily_timings/domain/services/schedule_calculator.dart';

enum DailyTimingsStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class DailyTimingsState extends Equatable {
  const DailyTimingsState({
    required this.status,
    required this.academicYearId,
    this.academicYearName,
    required this.timings,
    required this.computation,
    this.errorMessage,
    this.isSavedRecently = false,
  });

  factory DailyTimingsState.initial() {
    const defaultTimings = ScheduleTimingsEntity(
      id: '',
      academicYearId: '',
      assemblyTime: '07:45',
      startTime: '08:00',
      lunchAfterPeriod: 4,
      lunchDurationMinutes: 15,
      lunchStart: '10:40',
      lunchEnd: '10:55',
      endTime: '13:30',
      periodDurations: ScheduleCalculator.defaultPeriodDurations,
    );

    final initialComputation = ScheduleCalculator.computeSchedule(
      startTime: defaultTimings.startTime,
      periodDurations: defaultTimings.periodDurations,
      lunchDurationMinutes: defaultTimings.lunchDurationMinutes,
      lunchAfterPeriod: defaultTimings.lunchAfterPeriod,
    );

    return DailyTimingsState(
      status: DailyTimingsStatus.loaded,
      academicYearId: 'session-2024-2025-uuid',
      academicYearName: 'Academic Session 2024–2025',
      timings: defaultTimings,
      computation: initialComputation,
    );
  }

  final DailyTimingsStatus status;
  final String academicYearId;
  final String? academicYearName;
  final ScheduleTimingsEntity timings;
  final ScheduleComputationResult computation;
  final String? errorMessage;
  final bool isSavedRecently;

  DailyTimingsState copyWith({
    DailyTimingsStatus? status,
    String? academicYearId,
    String? academicYearName,
    ScheduleTimingsEntity? timings,
    ScheduleComputationResult? computation,
    String? errorMessage,
    bool? isSavedRecently,
  }) {
    return DailyTimingsState(
      status: status ?? this.status,
      academicYearId: academicYearId ?? this.academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      timings: timings ?? this.timings,
      computation: computation ?? this.computation,
      errorMessage: errorMessage ?? this.errorMessage,
      isSavedRecently: isSavedRecently ?? this.isSavedRecently,
    );
  }

  @override
  List<Object?> get props => [
        status,
        academicYearId,
        academicYearName,
        timings,
        computation,
        errorMessage,
        isSavedRecently,
      ];
}
