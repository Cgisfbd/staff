import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.failureToReturn, this.loginResponseToReturn});

  final Failure? failureToReturn;
  final LoginResponseEntity? loginResponseToReturn;

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String username,
    required String password,
  }) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      loginResponseToReturn ??
          const LoginResponseEntity(
            user: UserEntity(
              id: 'u-1',
              username: 'ustad.test',
              role: 'STAFF',
              isActive: true,
            ),
          ),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> verify2fa({
    required String tempToken,
    required String otp,
  }) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(
      UserEntity(
        id: 'u-1',
        username: 'ustad.test',
        role: 'STAFF',
        isActive: true,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }
}

void main() {
  group('LoginUseCase', () {
    test('should return ValidationFailure when username is empty', () async {
      final repo = MockAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase(username: '   ', password: 'password123');
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have failed'),
      );
    });

    test('should return ValidationFailure when password is empty', () async {
      final repo = MockAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase(username: 'ustad.test', password: '  ');
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have failed'),
      );
    });

    test('should return LoginResponseEntity on valid credentials', () async {
      final repo = MockAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase(username: 'ustad.test', password: 'password123');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should have succeeded'),
        (loginResp) {
          expect(loginResp.user?.username, equals('ustad.test'));
          expect(loginResp.user?.role, equals('STAFF'));
        },
      );
    });
  });
}
