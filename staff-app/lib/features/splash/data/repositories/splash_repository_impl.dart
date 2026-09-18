import 'package:fpdart/fpdart.dart';
import 'package:staff_app/core/error/failures.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/features/splash/domain/entities/splash_entity.dart';
import 'package:staff_app/features/splash/domain/repositories/splash_repository.dart';

/// Concrete Data Layer implementation of SplashRepository.
class SplashRepositoryImpl implements SplashRepository {
  const SplashRepositoryImpl({
    required SecureStorageService secureStorage,
    required HiveService hiveService,
  })  : _secureStorage = secureStorage,
        _hiveService = hiveService;

  final SecureStorageService _secureStorage;
  final HiveService _hiveService;

  @override
  Future<Either<Failure, SplashEntity>> checkInitStatus() async {
    try {
      // 1. Verify Keystore access
      final cipherKey = await _secureStorage.getOrCreateHiveCipherKey();
      final isKeystoreReady = cipherKey.isNotEmpty;

      // 2. Verify Encrypted Hive boxes are open
      bool isStorageReady = false;
      try {
        if (_hiveService.isInitialized) {
          isStorageReady = _hiveService.syncQueueBox.isOpen && _hiveService.cacheBox.isOpen;
        }
      } catch (_) {
        isStorageReady = false;
      }

      // 3. Check for existing authenticated session
      final token = await _secureStorage.getAccessToken();
      final hasActiveSession = token != null && token.isNotEmpty;

      final entity = SplashEntity(
        isKeystoreReady: isKeystoreReady,
        isStorageReady: isStorageReady,
        hasActiveSession: hasActiveSession,
        systemTimestamp: AppFormatters.nowUtcIso(),
      );

      AppLogger.info('App bootstrap verification complete: Keystore=$isKeystoreReady, Storage=$isStorageReady, Auth=$hasActiveSession');
      return Right(entity);
    } catch (e, st) {
      AppLogger.error('App bootstrap initialization check failed', e, st);
      return Left(CacheFailure('System initialization check failed: $e'));
    }
  }
}
