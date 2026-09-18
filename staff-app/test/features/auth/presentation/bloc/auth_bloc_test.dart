import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';
import 'package:staff_app/features/auth/domain/entities/user_entity.dart';
import 'package:staff_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:staff_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:staff_app/features/auth/domain/usecases/verify_2fa_usecase.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:staff_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.failureToReturn, this.loginResponseToReturn, this.userToReturn});

  final Failure? failureToReturn;
  final LoginResponseEntity? loginResponseToReturn;
  final UserEntity? userToReturn;

  static const defaultUser = UserEntity(
    id: 'u-1',
    username: 'ustad.test',
    role: 'STAFF',
    isActive: true,
  );

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String username,
    required String password,
  }) async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(loginResponseToReturn ?? const LoginResponseEntity(user: defaultUser));
  }

  @override
  Future<Either<Failure, UserEntity>> verify2fa({
    required String tempToken,
    required String otp,
  }) async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(userToReturn ?? defaultUser);
  }

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
}

void main() {
  group('AuthBloc', () {
    AuthBloc buildBloc(MockAuthRepository repo) => AuthBloc(
          loginUseCase: LoginUseCase(repo),
          verify2faUseCase: Verify2FAUseCase(repo),
          authRepository: repo,
        );

    test('initial state is AuthInitial', () async {
      final bloc = buildBloc(MockAuthRepository());
      expect(bloc.state, equals(const AuthInitial()));
      await bloc.close();
    });

    test('emits [AuthLoading, AuthAuthenticated] on successful direct login', () async {
      final bloc = buildBloc(MockAuthRepository());
      final expected = [const AuthLoading(), isA<AuthAuthenticated>()];
      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

      bloc.add(const LoginSubmitted(username: 'ustad.test', password: 'password123'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });

    test('emits [AuthLoading, AuthRequires2FA] when 2FA is required', () async {
      final repo = MockAuthRepository(
        loginResponseToReturn: const LoginResponseEntity(
          requires2fa: true,
          tempToken: 'temp-jwt-token',
          username: 'ustad.test',
        ),
      );
      final bloc = buildBloc(repo);
      final expected = [
        const AuthLoading(),
        const AuthRequires2FA(tempToken: 'temp-jwt-token', username: 'ustad.test'),
      ];
      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

      bloc.add(const LoginSubmitted(username: 'ustad.test', password: 'password123'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });

    test('emits [AuthLoading, AuthAuthenticated] on successful 2FA verification', () async {
      final bloc = buildBloc(MockAuthRepository());
      final expected = [const AuthLoading(), isA<AuthAuthenticated>()];
      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

      bloc.add(const Verify2FASubmitted(tempToken: 'temp-token', otp: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });

    test('emits [AuthLoading, AuthFailureState] on failure', () async {
      final repo = MockAuthRepository(
        failureToReturn: const AuthFailure('Invalid credentials provided'),
      );
      final bloc = buildBloc(repo);
      final expected = [
        const AuthLoading(),
        const AuthFailureState('Invalid credentials provided'),
      ];
      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

      bloc.add(const LoginSubmitted(username: 'ustad.test', password: 'wrongpassword'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });

    test('emits [AuthLoading, AuthUnauthenticated] on logout', () async {
      final bloc = buildBloc(MockAuthRepository());
      final expected = [const AuthLoading(), const AuthUnauthenticated()];
      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));

      bloc.add(const LogoutRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
    });
  });
}
