import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/utils/app_logger.dart';

/// AES-256 Encrypted Hive Local Database Service.
/// Hardware cipher key stored in Android Keystore / iOS Keychain enclave (staffRULES.md Tier 8).
class HiveService {
  HiveService(this._secureStorage);

  final SecureStorageService _secureStorage;
  bool _isInitialized = false;

  late Box<dynamic> _syncQueueBox;
  late Box<dynamic> _cacheBox;

  bool get isInitialized => _isInitialized;
  Box<dynamic> get syncQueueBox => _syncQueueBox;
  Box<dynamic> get cacheBox => _cacheBox;

  /// Initializes Hive and opens AES-256 encrypted boxes with hardware Keystore key.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      final Uint8List cipherKey = await _secureStorage.getOrCreateHiveCipherKey();
      final cipher = HiveAesCipher(cipherKey);

      _syncQueueBox = await Hive.openBox<dynamic>(
        AppConfig.offlineSyncQueueBox,
        encryptionCipher: cipher,
      );

      _cacheBox = await Hive.openBox<dynamic>(
        AppConfig.localCacheBox,
        encryptionCipher: cipher,
      );

      _isInitialized = true;
      AppLogger.info('Encrypted Hive storage initialized successfully with AES-256 cipher.');
    } catch (e, st) {
      AppLogger.error('Failed to initialize AES-256 Hive database', e, st);
      throw CacheException('Hive initialization failed: $e');
    }
  }

  /// Closes all open boxes safely on shutdown.
  Future<void> close() async {
    if (!_isInitialized) return;
    await Hive.close();
    _isInitialized = false;
  }
}
