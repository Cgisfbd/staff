import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Structured Enterprise Application Logger.
/// Replaces banned raw print() calls and provides level-based logging with ISO timestamps.
class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      dev.log(
        message,
        name: 'TaleemOne_ERP:DEBUG',
        time: DateTime.now().toUtc(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      dev.log(
        message,
        name: 'TaleemOne_ERP:INFO',
        time: DateTime.now().toUtc(),
      );
    }
  }

  static void warn(String message, [Object? error]) {
    dev.log(
      message,
      name: 'TaleemOne_ERP:WARN',
      time: DateTime.now().toUtc(),
      error: error,
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    dev.log(
      message,
      name: 'TaleemOne_ERP:ERROR',
      time: DateTime.now().toUtc(),
      error: error,
      stackTrace: stackTrace,
    );
  }
}
