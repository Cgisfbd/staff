import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/utils/app_logger.dart';

enum CircuitState { closed, open, halfOpen }

/// Circuit Breaker protecting device battery & network during server outages (staffRULES.md Phase 5).
/// Trips to OPEN on 5 consecutive failures, holds for 30s cooldown, then tests via HALF-OPEN.
class CircuitBreaker {
  CircuitState _state = CircuitState.closed;
  int _consecutiveFailures = 0;
  DateTime? _lastTrippedTime;

  CircuitState get state {
    if (_state == CircuitState.open && _lastTrippedTime != null) {
      final elapsed = DateTime.now().difference(_lastTrippedTime!);
      if (elapsed >= AppConfig.circuitBreakerCooldown) {
        _state = CircuitState.halfOpen;
        AppLogger.info('Circuit breaker entering HALF-OPEN state for canary verification.');
      }
    }
    return _state;
  }

  /// Verifies circuit health before allowing a request to proceed.
  void checkHealth() {
    if (state == CircuitState.open) {
      AppLogger.warn('Request blocked by Circuit Breaker (State: OPEN, Cooldown active)');
      throw CircuitBreakerException('Circuit breaker OPEN. Server in 30s cooldown.');
    }
  }

  /// Records a successful response. Resets failures and returns state to CLOSED.
  void recordSuccess() {
    if (_state != CircuitState.closed) {
      AppLogger.info('Circuit breaker closed after verified server recovery.');
    }
    _consecutiveFailures = 0;
    _state = CircuitState.closed;
    _lastTrippedTime = null;
  }

  /// Records a failure (5xx server error or network timeout).
  void recordFailure() {
    _consecutiveFailures++;
    AppLogger.warn('Circuit breaker failure count: $_consecutiveFailures/${AppConfig.circuitBreakerFailureThreshold}');

    if (_consecutiveFailures >= AppConfig.circuitBreakerFailureThreshold) {
      _state = CircuitState.open;
      _lastTrippedTime = DateTime.now();
      AppLogger.error('Circuit breaker TRIPPED to OPEN! Pausing retries for 30 seconds.');
    }
  }

  /// Forces reset for tests or explicit manual recovery.
  void reset() {
    _state = CircuitState.closed;
    _consecutiveFailures = 0;
    _lastTrippedTime = null;
  }
}
