import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:staff_app/features/settings/domain/entities/staff_profile_entity.dart';
import 'package:staff_app/features/settings/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, StaffProfileEntity>> getProfile() async {
    try {
      final json = await _remoteDataSource.getProfile();
      final entity = StaffProfileEntity(
        id: json['id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        fullName: json['name']?.toString() ??
            json['fullName']?.toString() ??
            json['username']?.toString() ??
            'Staff Member',
        role: json['role']?.toString() ?? 'STAFF',
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
        hasPin: json['hasPin'] == true,
        isTwoFactorEnabled: json['isTwoFactorEnabled'] == true,
      );
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePin({
    required String password,
    required String newPin,
    String? currentPin,
  }) async {
    try {
      await _remoteDataSource.changePin(
        password: password,
        newPin: newPin,
        currentPin: currentPin,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> uploadAvatar({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final avatarUrl = await _remoteDataSource.uploadAvatar(
        bytes: bytes,
        fileName: fileName,
      );
      return Right(avatarUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generate2FA() async {
    try {
      final result = await _remoteDataSource.generate2FA();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verify2FA(String token) async {
    try {
      await _remoteDataSource.verify2FA(token: token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disable2FA(String password) async {
    try {
      await _remoteDataSource.disable2FA(password: password);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
