import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/network/circuit_breaker.dart';

void main() {
  group('CircuitBreaker', () {
    late CircuitBreaker circuitBreaker;

    setUp(() {
      circuitBreaker = CircuitBreaker();
    });

    test('initial state should be CLOSED and checkHealth should not throw', () {
      expect(circuitBreaker.state, equals(CircuitState.closed));
      expect(() => circuitBreaker.checkHealth(), returnsNormally);
    });

    test('should trip to OPEN after 5 consecutive failures', () {
      for (int i = 0; i < AppConfig.circuitBreakerFailureThreshold - 1; i++) {
        circuitBreaker.recordFailure();
        expect(circuitBreaker.state, equals(CircuitState.closed));
      }

      // 5th failure trips the breaker
      circuitBreaker.recordFailure();
      expect(circuitBreaker.state, equals(CircuitState.open));

      // Subsequent health checks must throw CircuitBreakerException
      expect(
        () => circuitBreaker.checkHealth(),
        throwsA(isA<CircuitBreakerException>()),
      );
    });

    test('should reset to CLOSED when recordSuccess is called', () {
      // Trip the breaker
      for (int i = 0; i < AppConfig.circuitBreakerFailureThreshold; i++) {
        circuitBreaker.recordFailure();
      }
      expect(circuitBreaker.state, equals(CircuitState.open));

      // Recovery
      circuitBreaker.recordSuccess();
      expect(circuitBreaker.state, equals(CircuitState.closed));
      expect(() => circuitBreaker.checkHealth(), returnsNormally);
    });
  });
}
