import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_state.dart';

/// Central Cubit managing Institutional Mandatory App Lock (< 140 lines).
/// Strictly allows exactly ONE lock method (Phone Screen Lock vs In-App PIN).
/// Defaults to Phone Screen Lock automatically if configured on the device.
class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required SecureStorageService secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage,
        _localAuth = localAuth ?? LocalAuthentication(),
        super(const AppLockState());

  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth;

  static const String _keyMode = 'app_lock_mode';
  static const String _keyLocalPin = 'app_lock_local_pin_hash';
  static const String _keyLocalPinLength = 'app_lock_pin_length';

  Future<void> init() async {
    final modeStr = await _secureStorage.getString(_keyMode);
    final pinHash = await _secureStorage.getString(_keyLocalPin);
    final pinLenStr = await _secureStorage.getString(_keyLocalPinLength);
    final pinLen = int.tryParse(pinLenStr ?? '') ?? 6;
    final hasPin = pinHash != null && pinHash.isNotEmpty;

    bool phoneSupported = false;
    try {
      phoneSupported = await _localAuth.isDeviceSupported();
    } catch (_) {
      phoneSupported = false;
    }

    // Mandatory single-lock rule:
    // 1. If modeStr is explicitly 'phoneLock':
    //    Use phoneLock if supported, otherwise localPin if available.
    // 2. If modeStr is explicitly 'localPin':
    //    Strictly use localPin (if hasPin).
    // 3. If modeStr is not set (e.g. first run or migration):
    //    If user already created a local PIN, strictly preserve it!
    //    Otherwise default to phoneLock (if supported), else localPin.
    final AppLockMode activeMode;
    if (modeStr == 'phoneLock') {
      activeMode = phoneSupported ? AppLockMode.phoneLock : (hasPin ? AppLockMode.localPin : AppLockMode.phoneLock);
    } else if (modeStr == 'localPin') {
      activeMode = hasPin ? AppLockMode.localPin : AppLockMode.phoneLock;
    } else {
      if (hasPin) {
        activeMode = AppLockMode.localPin;
      } else if (phoneSupported) {
        activeMode = AppLockMode.phoneLock;
      } else {
        activeMode = AppLockMode.localPin;
      }
    }

    // Persist determined mode to ensure consistency across future restarts
    final persistedMode = activeMode == AppLockMode.localPin ? 'localPin' : 'phoneLock';
    if (modeStr != persistedMode) {
      await _secureStorage.setString(_keyMode, persistedMode);
    }

    emit(state.copyWith(
      isInitialized: true,
      isAppLockEnabled: true,
      lockMode: activeMode,
      hasLocalPin: hasPin,
      localPinLength: pinLen,
      isDeviceSupported: phoneSupported,
      isLocked: true,
    ));
  }

  void lock() {
    emit(state.copyWith(isLocked: true));
  }

  void unlock() {
    emit(state.copyWith(isLocked: false));
  }

  Future<bool> authenticateDevice() async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Unlock TaleemOne ERP with your fingerprint, face, PIN, pattern or password',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (didAuth) {
        unlock();
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      if (e.code == 'PasscodeNotSet' ||
          e.code == 'NotEnrolled' ||
          e.code == 'NotAvailable' ||
          e.code == 'OtherOperatingSystem') {
        // Phone has no screen lock configured in OS settings!
        emit(state.copyWith(
          isDeviceSupported: false,
          lockMode: AppLockMode.localPin,
        ));
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> switchToPhoneLock() async {
    final ok = await authenticateDevice();
    if (!ok) return false;

    await _secureStorage.setString(_keyMode, 'phoneLock');
    await _secureStorage.setString(_keyLocalPin, '');
    emit(state.copyWith(
      lockMode: AppLockMode.phoneLock,
      hasLocalPin: false,
    ));
    return true;
  }

  Future<void> switchToLocalPin(String pin) async {
    await setLocalPin(pin);
  }

  Future<bool> selectExistingLocalPin() async {
    if (!state.hasLocalPin) return false;
    await _secureStorage.setString(_keyMode, 'localPin');
    emit(state.copyWith(lockMode: AppLockMode.localPin));
    return true;
  }

  Future<void> setLocalPin(String pin) async {
    final hash = sha256.convert(utf8.encode(pin)).toString();
    await _secureStorage.setString(_keyLocalPin, hash);
    await _secureStorage.setString(_keyLocalPinLength, pin.length.toString());
    await _secureStorage.setString(_keyMode, 'localPin');
    emit(state.copyWith(
      hasLocalPin: true,
      localPinLength: pin.length,
      lockMode: AppLockMode.localPin,
    ));
  }

  Future<bool> checkLocalPin(String pin) async {
    final storedHash = await _secureStorage.getString(_keyLocalPin);
    if (storedHash == null || storedHash.isEmpty) return false;
    final currentHash = sha256.convert(utf8.encode(pin)).toString();
    return storedHash == currentHash;
  }

  Future<bool> verifyLocalPin(String pin) async {
    final storedHash = await _secureStorage.getString(_keyLocalPin);
    if (storedHash == null || storedHash.isEmpty) return false;
    final currentHash = sha256.convert(utf8.encode(pin)).toString();
    final match = storedHash == currentHash;
    if (match) {
      if (state.localPinLength != pin.length) {
        await updatePinLength(pin.length);
      }
      unlock();
    }
    return match;
  }

  Future<void> updatePinLength(int length) async {
    await _secureStorage.setString(_keyLocalPinLength, length.toString());
    emit(state.copyWith(localPinLength: length));
  }

  Future<void> clearLocalPin() async {
    await _secureStorage.setString(_keyLocalPin, '');
    await _secureStorage.setString(_keyMode, 'phoneLock');
    emit(state.copyWith(
      hasLocalPin: false,
      lockMode: AppLockMode.phoneLock,
    ));
  }
}
