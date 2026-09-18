import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/features/splash/domain/entities/splash_entity.dart';

/// Pure Dart Abstract Repository Contract (Dependency Inversion).
abstract class SplashRepository {
  Future<Either<Failure, SplashEntity>> checkInitStatus();
}
