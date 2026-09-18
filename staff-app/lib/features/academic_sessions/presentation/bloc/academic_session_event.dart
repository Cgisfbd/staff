import 'package:equatable/equatable.dart';

abstract class AcademicSessionEvent extends Equatable {
  const AcademicSessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadAcademicSessionsEvent extends AcademicSessionEvent {
  const LoadAcademicSessionsEvent();
}

class ToggleExpandSessionEvent extends AcademicSessionEvent {
  const ToggleExpandSessionEvent(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class CreateAcademicSessionEvent extends AcademicSessionEvent {
  const CreateAcademicSessionEvent({
    required this.yearName,
    required this.startDate,
  });

  final String yearName;
  final String startDate;

  @override
  List<Object?> get props => [yearName, startDate];
}

class LockAcademicSessionEvent extends AcademicSessionEvent {
  const LockAcademicSessionEvent({
    required this.id,
    required this.endDate,
    required this.pin,
  });

  final String id;
  final String endDate;
  final String pin;

  @override
  List<Object?> get props => [id, endDate, pin];
}
