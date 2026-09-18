import 'package:equatable/equatable.dart';

/// Pure Dart Entity representing system bootstrap status (0 Flutter dependencies).
class SplashEntity extends Equatable {
  const SplashEntity({
    required this.isKeystoreReady,
    required this.isStorageReady,
    required this.hasActiveSession,
    required this.systemTimestamp,
  });

  final bool isKeystoreReady;
  final bool isStorageReady;
  final bool hasActiveSession;
  final String systemTimestamp;

  @override
  List<Object?> get props => [
        isKeystoreReady,
        isStorageReady,
        hasActiveSession,
        systemTimestamp,
      ];
}
