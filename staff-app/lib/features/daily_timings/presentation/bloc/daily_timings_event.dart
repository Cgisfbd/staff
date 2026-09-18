import 'package:equatable/equatable.dart';

abstract class DailyTimingsEvent extends Equatable {
  const DailyTimingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadScheduleTimingsEvent extends DailyTimingsEvent {
  const LoadScheduleTimingsEvent({this.academicYearId});

  final String? academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

class UpdateAssemblyTimeEvent extends DailyTimingsEvent {
  const UpdateAssemblyTimeEvent(this.assemblyTime);

  final String assemblyTime;

  @override
  List<Object?> get props => [assemblyTime];
}

class UpdateStartTimeEvent extends DailyTimingsEvent {
  const UpdateStartTimeEvent(this.startTime);

  final String startTime;

  @override
  List<Object?> get props => [startTime];
}

class UpdateLunchSlotEvent extends DailyTimingsEvent {
  const UpdateLunchSlotEvent(this.lunchAfterPeriod);

  final int lunchAfterPeriod;

  @override
  List<Object?> get props => [lunchAfterPeriod];
}

class UpdateLunchDurationEvent extends DailyTimingsEvent {
  const UpdateLunchDurationEvent(this.lunchDurationMinutes);

  final int lunchDurationMinutes;

  @override
  List<Object?> get props => [lunchDurationMinutes];
}

class UpdatePeriodDurationEvent extends DailyTimingsEvent {
  const UpdatePeriodDurationEvent({
    required this.index,
    required this.durationMinutes,
  });

  final int index;
  final int durationMinutes;

  @override
  List<Object?> get props => [index, durationMinutes];
}

class ApplyPresetEvent extends DailyTimingsEvent {
  const ApplyPresetEvent({
    required this.assembly,
    required this.start,
    this.lunchDuration,
    this.lunchAfterPeriod,
    required this.name,
  });

  final String assembly;
  final String start;
  final int? lunchDuration;
  final int? lunchAfterPeriod;
  final String name;

  @override
  List<Object?> get props => [assembly, start, lunchDuration, lunchAfterPeriod, name];
}

class ResetTimingsEvent extends DailyTimingsEvent {
  const ResetTimingsEvent();
}

class SaveScheduleTimingsEvent extends DailyTimingsEvent {
  const SaveScheduleTimingsEvent();
}
