import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/splash/domain/entities/splash_entity.dart';
import 'package:staff_app/features/splash/domain/repositories/splash_repository.dart';

/// Single-responsibility pure Dart use-case for verifying system readiness.
class InitAppUseCase {
  const InitAppUseCase(this._repository);

  final SplashRepository _repository;

  Future<Either<Failure, SplashEntity>> call() {
    return _repository.checkInitStatus();
  }
}
