/// Global application configuration and environment constants.
/// Enforces dynamic institute identity (Single-Institute VPS) and universal branding attribution.
class AppConfig {
  AppConfig._();

  // Universal Platform Attribution (staffRULES.md Rule 1.1)
  static const String appName = 'TaleemOne ERP';
  static const String appSubTitle = 'Staff Portal';
  static const String platformAuthority = 'Powered by Barkat Tech';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Dedicated VPS Network Endpoints (Overrideable dynamically via --dart-define=BASE_URL=...)
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:3001/api',
  );
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Security & Inactivity Thresholds (staffRULES.md Rule 4)
  static const Duration sessionInactivityTimeout = Duration(minutes: 15);
  static const int circuitBreakerFailureThreshold = 5;
  static const Duration circuitBreakerCooldown = Duration(seconds: 30);

  // Offline Engine Parameters (staffRULES.md Rule 5)
  static const int maxOfflineSyncRetries = 5;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const String offlineSyncQueueBox = 'offline_sync_queue_box';
  static const String localCacheBox = 'staff_app_cache_box';
  static const String secureStoragePrefix = 'taleemone_staff_';

  // Dynamic Base URL runtime storage key
  static const String keyApiBaseUrl = 'api_base_url';

  // Mobile Security Shield Tier 1: SSL Certificate SHA-256 Fingerprint
  static const String backendCertificateFingerprint = String.fromEnvironment(
    'CERT_FINGERPRINT',
    defaultValue: '',
  );
}
