import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

class Verify2FASubmitted extends AuthEvent {
  const Verify2FASubmitted({
    required this.tempToken,
    required this.otp,
  });

  final String tempToken;
  final String otp;

  @override
  List<Object?> get props => [tempToken, otp];
}

class ResetToLogin extends AuthEvent {
  const ResetToLogin();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
