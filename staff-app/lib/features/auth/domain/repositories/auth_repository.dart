import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';

/// Pure Dart Repository Contract for Authentication (Dependency Inversion).
abstract class AuthRepository {
  Future<Either<Failure, LoginResponseEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, UserEntity>> verify2fa({
    required String tempToken,
    required String otp,
  });

  Future<Either<Failure, void>> logout();
}
