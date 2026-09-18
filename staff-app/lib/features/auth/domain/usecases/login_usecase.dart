import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';

/// Single-responsibility use-case for executing staff login.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, LoginResponseEntity>> call({
    required String username,
    required String password,
  }) {
    if (username.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Username cannot be empty.')));
    }
    if (password.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Password cannot be empty.')));
    }
    return _repository.login(
      username: username.trim(),
      password: password.trim(),
    );
  }
}
