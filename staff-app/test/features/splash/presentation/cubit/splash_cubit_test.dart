import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/splash/domain/entities/splash_entity.dart';
import 'package:staff_app/features/splash/domain/repositories/splash_repository.dart';
import 'package:staff_app/features/splash/domain/usecases/init_app_usecase.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:staff_app/features/splash/presentation/cubit/splash_state.dart';
import 'package:staff_app/features/institute_settings/domain/repositories/institute_settings_repository.dart' as staff_app;
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';
import 'package:staff_app/features/institute_settings/domain/usecases/get_institute_settings_usecase.dart';

class MockGetInstituteSettingsUseCase extends GetInstituteSettingsUseCase {
  MockGetInstituteSettingsUseCase() : super(MockInstituteSettingsRepository());

  @override
  Future<Either<Failure, InstituteSettingsEntity>> call({dynamic cancelToken}) async {
    return const Right(InstituteSettingsEntity());
  }
}

class MockInstituteSettingsRepository implements staff_app.InstituteSettingsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSplashRepository implements SplashRepository {
  MockSplashRepository({this.failureToReturn, this.entityToReturn});

  final Failure? failureToReturn;
  final SplashEntity? entityToReturn;

  @override
  Future<Either<Failure, SplashEntity>> checkInitStatus() async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      entityToReturn ??
          const SplashEntity(
            isKeystoreReady: true,
            isStorageReady: true,
            hasActiveSession: false,
            systemTimestamp: '2026-09-10T16:00:00.000Z',
          ),
    );
  }
}

void main() {
  group('SplashCubit', () {
    test('initial state is SplashInitial', () async {
      final repo = MockSplashRepository();
      final useCase = InitAppUseCase(repo);
      final getSettingsUseCase = MockGetInstituteSettingsUseCase();
      final cubit = SplashCubit(
        initAppUseCase: useCase,
        getInstituteSettingsUseCase: getSettingsUseCase,
      );

      expect(cubit.state, equals(const SplashInitial()));
      await cubit.close();
    });

    test('emits [SplashLoading, SplashSuccess] on successful initialization', () async {
      final repo = MockSplashRepository();
      final useCase = InitAppUseCase(repo);
      final getSettingsUseCase = MockGetInstituteSettingsUseCase();
      final cubit = SplashCubit(
        initAppUseCase: useCase,
        getInstituteSettingsUseCase: getSettingsUseCase,
      );

      final expectedStates = [
        const SplashLoading(),
        isA<SplashSuccess>(),
      ];

      unawaited(expectLater(cubit.stream, emitsInOrder(expectedStates)));

      await cubit.initialize();
      await cubit.close();
    });

    test('emits [SplashLoading, SplashFailure] on failed initialization', () async {
      final repo = MockSplashRepository(
        failureToReturn: const CacheFailure('Keystore unavailable'),
      );
      final useCase = InitAppUseCase(repo);
      final getSettingsUseCase = MockGetInstituteSettingsUseCase();
      final cubit = SplashCubit(
        initAppUseCase: useCase,
        getInstituteSettingsUseCase: getSettingsUseCase,
      );

      final expectedStates = [
        const SplashLoading(),
        const SplashFailure('Keystore unavailable'),
      ];

      unawaited(expectLater(cubit.stream, emitsInOrder(expectedStates)));

      await cubit.initialize();
      await cubit.close();
    });
  });
}
