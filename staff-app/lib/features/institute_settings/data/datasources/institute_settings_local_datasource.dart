import 'package:staff_app/core/storage/hive_service.dart';
import 'package:staff_app/core/storage/offline_sync_queue.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';

abstract class InstituteSettingsLocalDataSource {
  Future<InstituteSettingsUiModel?> getLastCachedSettings();
  Future<void> cacheSettings(InstituteSettingsUiModel model);
  Future<void> queueSettingsUpdate(InstituteSettingsUiModel model);
}

class InstituteSettingsLocalDataSourceImpl implements InstituteSettingsLocalDataSource {
  InstituteSettingsLocalDataSourceImpl({
    required this.hiveService,
    required this.offlineSyncQueue,
  });

  final HiveService hiveService;
  final OfflineSyncQueue offlineSyncQueue;

  static const String _settingsCacheKey = 'institute_settings_cache';

  @override
  Future<InstituteSettingsUiModel?> getLastCachedSettings() async {
    try {
      final raw = hiveService.cacheBox.get(_settingsCacheKey);
      if (raw is Map) {
        return InstituteSettingsUiModel.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (e) {
      AppLogger.warn('Error reading institute settings from Hive cache: $e');
    }
    return null;
  }

  @override
  Future<void> cacheSettings(InstituteSettingsUiModel model) async {
    try {
      await hiveService.cacheBox.put(_settingsCacheKey, model.toJson());
    } catch (e) {
      AppLogger.warn('Error writing institute settings to Hive cache: $e');
    }
  }

  @override
  Future<void> queueSettingsUpdate(InstituteSettingsUiModel model) async {
    try {
      await cacheSettings(model);
      await offlineSyncQueue.enqueue(
        endpoint: '/v1/institute/settings',
        method: 'PATCH',
        payload: model.toJson(),
      );
      AppLogger.info('Institute settings mutation queued for offline background sync.');
    } catch (e) {
      AppLogger.error('Failed to enqueue institute settings offline sync: $e');
    }
  }
}
