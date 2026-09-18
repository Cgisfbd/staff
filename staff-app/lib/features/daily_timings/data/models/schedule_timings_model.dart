import 'package:staff_app/features/daily_timings/domain/entities/schedule_timings_entity.dart';
import 'package:staff_app/features/daily_timings/domain/services/schedule_calculator.dart';

class ScheduleTimingsModel extends ScheduleTimingsEntity {
  const ScheduleTimingsModel({
    required super.id,
    required super.academicYearId,
    required super.assemblyTime,
    required super.startTime,
    required super.lunchAfterPeriod,
    required super.lunchDurationMinutes,
    required super.lunchStart,
    required super.lunchEnd,
    required super.endTime,
    required super.periodDurations,
    super.updatedAt,
  });

  factory ScheduleTimingsModel.defaultTimings(String academicYearId) {
    final calc = ScheduleCalculator.computeSchedule(
      startTime: '08:00',
      periodDurations: ScheduleCalculator.defaultPeriodDurations,
      lunchDurationMinutes: 15,
      lunchAfterPeriod: 4,
    );

    return ScheduleTimingsModel(
      id: 'default-$academicYearId',
      academicYearId: academicYearId,
      assemblyTime: '07:45',
      startTime: '08:00',
      lunchAfterPeriod: 4,
      lunchDurationMinutes: 15,
      lunchStart: calc.lunchStart,
      lunchEnd: calc.lunchEnd,
      endTime: calc.endTime,
      periodDurations: ScheduleCalculator.defaultPeriodDurations,
      updatedAt: DateTime.now(),
    );
  }

  factory ScheduleTimingsModel.fromJson(Map<String, dynamic> json, {String? fallbackYearId}) {
    final yearId = json['academicYearId']?.toString() ?? fallbackYearId ?? '';
    final periodsRaw = json['periodDurations'];
    List<int> periods = ScheduleCalculator.defaultPeriodDurations;
    if (periodsRaw is List) {
      periods = periodsRaw.map((e) => (e as num).toInt()).toList();
      if (periods.length < 8) {
        periods = List.from(periods)..addAll(List.filled(8 - periods.length, 40));
      }
    }

    final start = json['startTime']?.toString() ?? '08:00';
    final lAfter = (json['lunchAfterPeriod'] as num?)?.toInt() ?? 4;
    final lDur = (json['lunchDurationMinutes'] as num?)?.toInt() ?? 15;

    final calc = ScheduleCalculator.computeSchedule(
      startTime: start,
      periodDurations: periods,
      lunchDurationMinutes: lDur,
      lunchAfterPeriod: lAfter,
    );

    return ScheduleTimingsModel(
      id: json['id']?.toString() ?? 'default-$yearId',
      academicYearId: yearId,
      assemblyTime: json['assemblyTime']?.toString() ?? '07:45',
      startTime: start,
      lunchAfterPeriod: lAfter,
      lunchDurationMinutes: lDur,
      lunchStart: json['lunchStart']?.toString() ?? calc.lunchStart,
      lunchEnd: json['lunchEnd']?.toString() ?? calc.lunchEnd,
      endTime: json['endTime']?.toString() ?? calc.endTime,
      periodDurations: periods,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assemblyTime': assemblyTime,
      'startTime': startTime,
      'lunchAfterPeriod': lunchAfterPeriod,
      'lunchDurationMinutes': lunchDurationMinutes,
      'periodDurations': periodDurations,
    };
  }
}
