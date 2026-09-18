import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:staff_app/config/app_config.dart';

/// Hardware-Backed Encrypted Session Storage Service.
/// Strictly uses Android Keystore and iOS Keychain secure enclave (staffRULES.md Tier 2).
/// Insecure SharedPreferences is 100% bypassed.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = '${AppConfig.secureStoragePrefix}access_token';
  static const String _keyRefreshToken = '${AppConfig.secureStoragePrefix}refresh_token';
  static const String _keySessionSecret = '${AppConfig.secureStoragePrefix}session_hmac_secret';
  static const String _keyHiveCipher = '${AppConfig.secureStoragePrefix}hive_cipher_key';
  static const String _keyApiBaseUrl = '${AppConfig.secureStoragePrefix}api_base_url';
  static const String _keyUserProfile = '${AppConfig.secureStoragePrefix}user_profile';

  // User Profile JSON Cache
  Future<String?> getUserProfile() => _storage.read(key: _keyUserProfile);
  Future<void> setUserProfile(String profile) =>
      _storage.write(key: _keyUserProfile, value: profile);

  // Access Token
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<void> setAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  // Refresh Token
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);
  Future<void> setRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  // Dynamic Session HMAC Secret (Zero Static Secret Law)
  Future<String?> getSessionHmacSecret() => _storage.read(key: _keySessionSecret);
  Future<void> setSessionHmacSecret(String secret) =>
      _storage.write(key: _keySessionSecret, value: secret);

  // Dynamic API Base URL
  Future<String?> getApiBaseUrl() => _storage.read(key: _keyApiBaseUrl);
  Future<void> setApiBaseUrl(String url) =>
      _storage.write(key: _keyApiBaseUrl, value: url);

  // Generic Key-Value Enclave Operations
  Future<String?> getString(String key) => _storage.read(key: key);
  Future<void> setString(String key, String value) =>
      _storage.write(key: key, value: value);

  // Hardware Keystore Encrypted Key for Hive AES-256 local database
  Future<Uint8List> getOrCreateHiveCipherKey() async {
    final existingKeyBase64 = await _storage.read(key: _keyHiveCipher);
    if (existingKeyBase64 != null && existingKeyBase64.isNotEmpty) {
      return base64Decode(existingKeyBase64);
    }

    // Generate cryptographically secure 256-bit (32 bytes) key
    final random = Random.secure();
    final keyBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      keyBytes[i] = random.nextInt(256);
    }

    await _storage.write(
      key: _keyHiveCipher,
      value: base64Encode(keyBytes),
    );
    return keyBytes;
  }

  // Safe Session Wipe (Preserves device-level Hive encryption key)
  Future<void> clearAuthSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keySessionSecret),
      _storage.delete(key: _keyUserProfile),
    ]);
  }

  // Complete purge
  Future<void> wipeAll() => _storage.deleteAll();
}
