import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:staff_app/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_state.dart';

/// Central BLoC managing staff authentication state (< 80 lines).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required Verify2FAUseCase verify2faUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _verify2faUseCase = verify2faUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<Verify2FASubmitted>(_onVerify2FASubmitted);
    on<ResetToLogin>(_onResetToLogin);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _loginUseCase;
  final Verify2FAUseCase _verify2faUseCase;
  final AuthRepository _authRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (loginResponse) {
        if (loginResponse.requires2fa && loginResponse.tempToken != null) {
          emit(AuthRequires2FA(
            tempToken: loginResponse.tempToken!,
            username: loginResponse.username ?? event.username,
          ));
        } else if (loginResponse.user != null) {
          emit(AuthAuthenticated(loginResponse.user!));
        } else {
          emit(const AuthFailureState('Authentication failed. No user profile returned.'));
        }
      },
    );
  }

  Future<void> _onVerify2FASubmitted(
    Verify2FASubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _verify2faUseCase(
      tempToken: event.tempToken,
      otp: event.otp,
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onResetToLogin(
    ResetToLogin event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
