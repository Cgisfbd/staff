import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/settings/domain/entities/staff_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, StaffProfileEntity>> getProfile();
  Future<Either<Failure, void>> changePassword({required String currentPassword, required String newPassword});
  Future<Either<Failure, void>> changePin({required String password, required String newPin, String? currentPin});
  Future<Either<Failure, String?>> uploadAvatar({required List<int> bytes, required String fileName});
  Future<Either<Failure, Map<String, dynamic>>> generate2FA();
  Future<Either<Failure, void>> verify2FA(String token);
  Future<Either<Failure, void>> disable2FA(String password);
}
