import 'package:equatable/equatable.dart';

/// Exclusive App Lock methods (Phone Screen Lock vs Local In-App PIN).
enum AppLockMode {
  phoneLock,
  localPin,
}

/// State representing mandatory single-lock App Security Enclave.
class AppLockState extends Equatable {
  const AppLockState({
    this.isInitialized = false,
    this.isAppLockEnabled = true, // Mandatory: exactly one lock is always enforced
    this.lockMode = AppLockMode.phoneLock,
    this.hasLocalPin = false,
    this.localPinLength = 6,
    this.isDeviceSupported = true,
    this.isLocked = true,
    this.errorMessage,
  });

  final bool isInitialized;
  final bool isAppLockEnabled;
  final AppLockMode lockMode;
  final bool hasLocalPin;
  final int localPinLength;
  final bool isDeviceSupported;
  final bool isLocked;
  final String? errorMessage;

  AppLockState copyWith({
    bool? isInitialized,
    bool? isAppLockEnabled,
    AppLockMode? lockMode,
    bool? hasLocalPin,
    int? localPinLength,
    bool? isDeviceSupported,
    bool? isLocked,
    String? errorMessage,
  }) {
    return AppLockState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      lockMode: lockMode ?? this.lockMode,
      hasLocalPin: hasLocalPin ?? this.hasLocalPin,
      localPinLength: localPinLength ?? this.localPinLength,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      isLocked: isLocked ?? this.isLocked,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        isAppLockEnabled,
        lockMode,
        hasLocalPin,
        localPinLength,
        isDeviceSupported,
        isLocked,
        errorMessage,
      ];
}
