import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/create_academic_session_usecase.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/get_academic_sessions_usecase.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/get_next_session_info_usecase.dart';
import 'package:staff_app/features/academic_sessions/domain/usecases/lock_academic_session_usecase.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_event.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_state.dart';

class AcademicSessionBloc extends Bloc<AcademicSessionEvent, AcademicSessionState> {
  AcademicSessionBloc({
    required this.getAcademicSessionsUseCase,
    required this.getNextSessionInfoUseCase,
    required this.createAcademicSessionUseCase,
    required this.lockAcademicSessionUseCase,
  }) : super(const AcademicSessionInitial()) {
    on<LoadAcademicSessionsEvent>(_onLoadAcademicSessions);
    on<ToggleExpandSessionEvent>(_onToggleExpandSession);
    on<CreateAcademicSessionEvent>(_onCreateAcademicSession);
    on<LockAcademicSessionEvent>(_onLockAcademicSession);
  }

  final GetAcademicSessionsUseCase getAcademicSessionsUseCase;
  final GetNextSessionInfoUseCase getNextSessionInfoUseCase;
  final CreateAcademicSessionUseCase createAcademicSessionUseCase;
  final LockAcademicSessionUseCase lockAcademicSessionUseCase;

  Future<void> _onLoadAcademicSessions(
    LoadAcademicSessionsEvent event,
    Emitter<AcademicSessionState> emit,
  ) async {
    emit(const AcademicSessionLoading());
    final sessionsResult = await getAcademicSessionsUseCase();
    final nextInfoResult = await getNextSessionInfoUseCase();

    sessionsResult.fold(
      (failure) => emit(AcademicSessionError(failure.message)),
      (sessions) {
        final nextInfo = nextInfoResult.getRight().toNullable();
        // Auto-expand active session initially if available
        final activeId = sessions.where((s) => s.isActive).map((s) => s.id).firstOrNull ??
            (sessions.isNotEmpty ? sessions.first.id : null);

        emit(AcademicSessionLoaded(
          sessions: sessions,
          expandedSessionId: activeId,
          nextSessionInfo: nextInfo,
        ));
      },
    );
  }

  void _onToggleExpandSession(
    ToggleExpandSessionEvent event,
    Emitter<AcademicSessionState> emit,
  ) {
    if (state is AcademicSessionLoaded) {
      final current = state as AcademicSessionLoaded;
      final newExpandedId = current.expandedSessionId == event.sessionId ? null : event.sessionId;
      emit(current.copyWith(expandedSessionId: () => newExpandedId));
    }
  }

  Future<void> _onCreateAcademicSession(
    CreateAcademicSessionEvent event,
    Emitter<AcademicSessionState> emit,
  ) async {
    if (state is! AcademicSessionLoaded) return;
    final current = state as AcademicSessionLoaded;
    emit(current.copyWith(isActionLoading: true));

    final result = await createAcademicSessionUseCase(
      yearName: event.yearName,
      startDate: event.startDate,
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(isActionLoading: false));
        // Error can be handled via toast or state
      },
      (newSession) async {
        // Reload all sessions
        final sessionsResult = await getAcademicSessionsUseCase();
        final nextInfoResult = await getNextSessionInfoUseCase();

        sessionsResult.fold(
          (failure) => emit(current.copyWith(isActionLoading: false)),
          (updatedSessions) {
            emit(AcademicSessionLoaded(
              sessions: updatedSessions,
              expandedSessionId: newSession.id,
              nextSessionInfo: nextInfoResult.getRight().toNullable(),
              isActionLoading: false,
              actionSuccessMessage: 'Session ${newSession.yearName} initialized successfully!',
            ));
          },
        );
      },
    );
  }

  Future<void> _onLockAcademicSession(
    LockAcademicSessionEvent event,
    Emitter<AcademicSessionState> emit,
  ) async {
    if (state is! AcademicSessionLoaded) return;
    final current = state as AcademicSessionLoaded;
    emit(current.copyWith(isActionLoading: true));

    final result = await lockAcademicSessionUseCase(
      id: event.id,
      endDate: event.endDate,
      pin: event.pin,
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(isActionLoading: false));
      },
      (lockedSession) async {
        final sessionsResult = await getAcademicSessionsUseCase();
        final nextInfoResult = await getNextSessionInfoUseCase();

        sessionsResult.fold(
          (failure) => emit(current.copyWith(isActionLoading: false)),
          (updatedSessions) {
            emit(AcademicSessionLoaded(
              sessions: updatedSessions,
              expandedSessionId: lockedSession.id,
              nextSessionInfo: nextInfoResult.getRight().toNullable(),
              isActionLoading: false,
              actionSuccessMessage: 'Session ${lockedSession.yearName} has been sealed & locked.',
            ));
          },
        );
      },
    );
  }
}
