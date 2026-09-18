import 'package:equatable/equatable.dart';
import 'package:staff_app/features/splash/domain/entities/splash_entity.dart';

/// Immutable states for Splash bootstrap flow.
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashSuccess extends SplashState {
  const SplashSuccess(this.entity);

  final SplashEntity entity;

  @override
  List<Object?> get props => [entity];
}

class SplashFailure extends SplashState {
  const SplashFailure(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
