import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/network/circuit_breaker.dart';
import 'package:staff_app/core/network/interceptors/auth_interceptor.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/utils/app_logger.dart';

/// Single Centralized Network Gateway (staffRULES.md Rule 6.1, < 140 lines).
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    required CircuitBreaker circuitBreaker,
    Dio? dio,
  })  : _secureStorage = secureStorage,
        _circuitBreaker = circuitBreaker {
    final opts = BaseOptions(
      baseUrl: AppConfig.defaultApiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'TaleemOne-ERP-StaffApp/1.0.0 (Android; Mobile)',
      },
    );

    final refreshDio = Dio(opts);
    if (dio == null) {
      _dio = Dio(opts);
      _dio.httpClientAdapter = _createSecureHttpClientAdapter();
      refreshDio.httpClientAdapter = _createSecureHttpClientAdapter();
    } else {
      _dio = dio;
    }

    _dio.interceptors.add(
      AuthInterceptor(
        secureStorage: _secureStorage,
        refreshDio: refreshDio,
        onSessionExpired: () => AppLogger.warn('Session expired permanently.'),
      ),
    );
  }

  static HttpClientAdapter _createSecureHttpClientAdapter() {
    return IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(
          context: SecurityContext(withTrustedRoots: true),
        );
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          final isDevHost = host == '127.0.0.1' ||
              host == 'localhost' ||
              host == '10.0.2.2' ||
              host.startsWith('192.168.') ||
              host.startsWith('10.');
          if (isDevHost) return true;
          if (AppConfig.backendCertificateFingerprint.isNotEmpty) {
            final digest = sha256.convert(cert.der);
            final fingerprint = digest.bytes
                .map((int b) => b.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();
            return fingerprint == AppConfig.backendCertificateFingerprint.toUpperCase();
          }
          return false;
        };
        return client;
      },
    );
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final CircuitBreaker _circuitBreaker;

  Dio get rawDio => _dio;

  Future<void> updateBaseUrl(String newUrl) async {
    _dio.options.baseUrl = newUrl;
    await _secureStorage.setApiBaseUrl(newUrl);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _execute(() => _dio.get<T>(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken));

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _execute(() => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _execute(() => _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));

  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _execute(() => _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _execute(() => _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken));

  Future<Response<T>> _execute<T>(Future<Response<T>> Function() request) async {
    _circuitBreaker.checkHealth();
    try {
      final response = await request();
      _circuitBreaker.recordSuccess();
      return response;
    } on DioException catch (dioErr) {
      if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout ||
          dioErr.type == DioExceptionType.sendTimeout ||
          (dioErr.response?.statusCode != null && dioErr.response!.statusCode! >= 500)) {
        _circuitBreaker.recordFailure();
      }

      final code = dioErr.response?.statusCode;
      final data = dioErr.response?.data;
      String message = 'Unable to connect to server.';

      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      } else if (dioErr.type == DioExceptionType.connectionError) {
        message = 'Server is unreachable. Please check connection or try again later.';
        throw NetworkException(message);
      } else if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        message = 'Server response timed out. Please try again.';
        throw NetworkException(message);
      } else if (code == 401) {
        message = 'Invalid credentials provided.';
      } else if (code != null && code >= 500) {
        message = 'Server temporarily unavailable. Please try again shortly.';
      }

      throw ServerException(message: message, statusCode: code);
    } catch (e) {
      if (e is CircuitBreakerException || e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
