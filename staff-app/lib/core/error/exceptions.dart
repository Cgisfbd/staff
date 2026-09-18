/// Core Data Layer Exceptions thrown by DataSources (Remote and Local).
class ServerException implements Exception {
  ServerException({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => 'ServerException: $message (status: $statusCode, code: $code)';
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No network connectivity']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  AuthException([this.message = 'Authentication failed']);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class SecurityException implements Exception {
  SecurityException(this.message);
  final String message;

  @override
  String toString() => 'SecurityException: $message';
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache read/write failure']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class CircuitBreakerException implements Exception {
  CircuitBreakerException([this.message = 'Circuit breaker is open']);
  final String message;

  @override
  String toString() => 'CircuitBreakerException: $message';
}
