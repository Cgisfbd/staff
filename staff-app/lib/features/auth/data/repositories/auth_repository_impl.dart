import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';

/// Concrete Data Layer implementation of AuthRepository (< 65 lines).
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CircuitBreakerException catch (e) {
      return Left(CircuitBreakerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected login error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verify2fa({
    required String tempToken,
    required String otp,
  }) async {
    try {
      final user = await _remoteDataSource.verify2fa(
        tempToken: tempToken,
        otp: otp,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CircuitBreakerException catch (e) {
      return Left(CircuitBreakerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('2FA verification error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Logout failed: $e'));
    }
  }
}
