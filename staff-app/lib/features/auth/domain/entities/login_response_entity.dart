import 'package:equatable/equatable.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';

/// Pure Dart Domain Entity for Login Response (supports normal login and 2FA challenge).
class LoginResponseEntity extends Equatable {
  const LoginResponseEntity({
    this.user,
    this.requires2fa = false,
    this.tempToken,
    this.username,
  });

  final UserEntity? user;
  final bool requires2fa;
  final String? tempToken;
  final String? username;

  @override
  List<Object?> get props => [user, requires2fa, tempToken, username];
}
