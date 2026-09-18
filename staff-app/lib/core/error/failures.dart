import 'package:equatable/equatable.dart';

/// Pure Dart Domain Failure hierarchy (Zero Flutter dependencies).
/// Used in `Either<Failure, T>` return patterns across all use-cases and repositories.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, this.code});

  final int? statusCode;
  final String? code;

  @override
  List<Object?> get props => [message, statusCode, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable. Operating in offline mode.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Session expired or unauthenticated.']);
}

class SecurityFailure extends Failure {
  const SecurityFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to read or write local encrypted cache.']);
}

class CircuitBreakerFailure extends Failure {
  const CircuitBreakerFailure([super.message = 'Server temporarily unavailable. Circuit breaker OPEN.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  final Map<String, dynamic> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}
