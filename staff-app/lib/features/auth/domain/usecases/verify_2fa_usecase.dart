import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';

/// Single-responsibility use-case for verifying 2FA TOTP code (< 30 lines).
class Verify2FAUseCase {
  const Verify2FAUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String tempToken,
    required String otp,
  }) {
    final cleanOtp = otp.trim();
    if (cleanOtp.length != 6 || int.tryParse(cleanOtp) == null) {
      return Future.value(const Left(ValidationFailure('Please enter a valid 6-digit verification code.')));
    }
    if (tempToken.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('2FA session token missing. Please log in again.')));
    }
    return _repository.verify2fa(
      tempToken: tempToken.trim(),
      otp: cleanOtp,
    );
  }
}
