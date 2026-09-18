import 'package:equatable/equatable.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthRequires2FA extends AuthState {
  const AuthRequires2FA({
    required this.tempToken,
    required this.username,
  });

  final String tempToken;
  final String username;

  @override
  List<Object?> get props => [tempToken, username];
}

class AuthFailureState extends AuthState {
  const AuthFailureState(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
