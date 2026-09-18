import 'package:equatable/equatable.dart';

/// Pure domain entity representing daily academic schedule timings
class ScheduleTimingsEntity extends Equatable {
  const ScheduleTimingsEntity({
    required this.id,
    required this.academicYearId,
    required this.assemblyTime,
    required this.startTime,
    required this.lunchAfterPeriod,
    required this.lunchDurationMinutes,
    required this.lunchStart,
    required this.lunchEnd,
    required this.endTime,
    required this.periodDurations,
    this.updatedAt,
  });

  final String id;
  final String academicYearId;
  final String assemblyTime;
  final String startTime;
  final int lunchAfterPeriod;
  final int lunchDurationMinutes;
  final String lunchStart;
  final String lunchEnd;
  final String endTime;
  final List<int> periodDurations;
  final DateTime? updatedAt;

  ScheduleTimingsEntity copyWith({
    String? id,
    String? academicYearId,
    String? assemblyTime,
    String? startTime,
    int? lunchAfterPeriod,
    int? lunchDurationMinutes,
    String? lunchStart,
    String? lunchEnd,
    String? endTime,
    List<int>? periodDurations,
    DateTime? updatedAt,
  }) {
    return ScheduleTimingsEntity(
      id: id ?? this.id,
      academicYearId: academicYearId ?? this.academicYearId,
      assemblyTime: assemblyTime ?? this.assemblyTime,
      startTime: startTime ?? this.startTime,
      lunchAfterPeriod: lunchAfterPeriod ?? this.lunchAfterPeriod,
      lunchDurationMinutes: lunchDurationMinutes ?? this.lunchDurationMinutes,
      lunchStart: lunchStart ?? this.lunchStart,
      lunchEnd: lunchEnd ?? this.lunchEnd,
      endTime: endTime ?? this.endTime,
      periodDurations: periodDurations ?? List.from(this.periodDurations),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        academicYearId,
        assemblyTime,
        startTime,
        lunchAfterPeriod,
        lunchDurationMinutes,
        lunchStart,
        lunchEnd,
        endTime,
        periodDurations,
        updatedAt,
      ];
}

/// Represents one single calculated period slot in the academic day
class CalculatedPeriod extends Equatable {
  const CalculatedPeriod({
    required this.slot,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.timeFormatted,
  });

  final int slot;
  final String label;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String timeFormatted;

  @override
  List<Object?> get props => [
        slot,
        label,
        startTime,
        endTime,
        durationMinutes,
        timeFormatted,
      ];
}

/// Dynamic live computation result for the entire school day
class ScheduleComputationResult extends Equatable {
  const ScheduleComputationResult({
    required this.periods,
    required this.lunchAfterPeriod,
    required this.isLunchEnabled,
    required this.lunchStart,
    required this.lunchEnd,
    required this.lunchDurationMinutes,
    required this.endTime,
    required this.totalTeachingMins,
    required this.instructionText,
  });

  final List<CalculatedPeriod> periods;
  final int lunchAfterPeriod;
  final bool isLunchEnabled;
  final String lunchStart;
  final String lunchEnd;
  final int lunchDurationMinutes;
  final String endTime;
  final int totalTeachingMins;
  final String instructionText;

  @override
  List<Object?> get props => [
        periods,
        lunchAfterPeriod,
        isLunchEnabled,
        lunchStart,
        lunchEnd,
        lunchDurationMinutes,
        endTime,
        totalTeachingMins,
        instructionText,
      ];
}
