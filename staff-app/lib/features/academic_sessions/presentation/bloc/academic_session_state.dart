import 'package:equatable/equatable.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';

abstract class AcademicSessionState extends Equatable {
  const AcademicSessionState();

  @override
  List<Object?> get props => [];
}

class AcademicSessionInitial extends AcademicSessionState {
  const AcademicSessionInitial();
}

class AcademicSessionLoading extends AcademicSessionState {
  const AcademicSessionLoading();
}

class AcademicSessionLoaded extends AcademicSessionState {
  const AcademicSessionLoaded({
    required this.sessions,
    this.expandedSessionId,
    this.nextSessionInfo,
    this.isActionLoading = false,
    this.actionSuccessMessage,
  });

  final List<AcademicSessionEntity> sessions;
  final String? expandedSessionId;
  final NextSessionInfoEntity? nextSessionInfo;
  final bool isActionLoading;
  final String? actionSuccessMessage;

  AcademicSessionEntity? get activeSession {
    try {
      return sessions.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  AcademicSessionLoaded copyWith({
    List<AcademicSessionEntity>? sessions,
    String? Function()? expandedSessionId,
    NextSessionInfoEntity? nextSessionInfo,
    bool? isActionLoading,
    String? actionSuccessMessage,
  }) {
    return AcademicSessionLoaded(
      sessions: sessions ?? this.sessions,
      expandedSessionId: expandedSessionId != null ? expandedSessionId() : this.expandedSessionId,
      nextSessionInfo: nextSessionInfo ?? this.nextSessionInfo,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        sessions,
        expandedSessionId,
        nextSessionInfo,
        isActionLoading,
        actionSuccessMessage,
      ];
}

class AcademicSessionError extends AcademicSessionState {
  const AcademicSessionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
