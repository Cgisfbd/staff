import 'dart:async';

import 'package:dio/dio.dart';
import 'package:staff_app/config/app_config.dart';
import 'package:staff_app/core/security/hmac_signer.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

typedef OnSessionExpired = void Function();

/// Central Security Interceptor implementing security headers and FIFO Mutex Silent Refresh.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required Dio refreshDio,
    this.onSessionExpired,
  })  : _secureStorage = secureStorage,
        _refreshDio = refreshDio;

  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  final OnSessionExpired? onSessionExpired;

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _retryQueue = [];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) options.headers['Authorization'] = 'Bearer $token';

      final method = options.method.toUpperCase();
      if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(method)) {
        final nonce = const Uuid().v4();
        final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
        options.headers['X-Request-Nonce'] = nonce;
        options.headers['X-Timestamp'] = timestamp;
        options.headers.putIfAbsent('X-Idempotency-Key', () => const Uuid().v4());

        final sessionSecret = await _secureStorage.getSessionHmacSecret();
        if (sessionSecret != null && sessionSecret.isNotEmpty) {
          options.headers['X-App-Signature'] = HmacSigner.signRequest(
            timestamp: timestamp,
            nonce: nonce,
            body: options.data,
            sessionSecret: sessionSecret,
          );
        }
      }
      return handler.next(options);
    } catch (e, st) {
      AppLogger.error('Error attaching security headers', e, st);
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');

    if (is401 && !isRefreshCall) {
      if (_isRefreshing) {
        _retryQueue.add((options: err.requestOptions, handler: handler));
        return;
      }
      _isRefreshing = true;
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) throw Exception('No refresh token');

        final baseUrl = await _secureStorage.getApiBaseUrl() ?? AppConfig.defaultApiBaseUrl;
        final res = await _refreshDio.post<Map<String, dynamic>>(
          '$baseUrl/v1/auth/refresh',
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
          data: {'refreshToken': refreshToken},
        );

        final data = res.data?['data'] as Map<String, dynamic>? ?? res.data;
        final newAccess = data?['accessToken']?.toString() ?? (data?['tokens'] as Map?)?['accessToken']?.toString();
        final newRefresh = data?['refreshToken']?.toString() ?? (data?['tokens'] as Map?)?['refreshToken']?.toString();

        if (newAccess == null || newAccess.isEmpty) throw Exception('Invalid refresh token response');

        await _secureStorage.setAccessToken(newAccess);
        if (newRefresh != null && newRefresh.isNotEmpty) await _secureStorage.setRefreshToken(newRefresh);

        final retryResponse = await _retryRequest(err.requestOptions, newAccess);
        handler.resolve(retryResponse);

        while (_retryQueue.isNotEmpty) {
          final queued = _retryQueue.removeAt(0);
          try {
            queued.handler.resolve(await _retryRequest(queued.options, newAccess));
          } catch (qErr) {
            queued.handler.reject(qErr is DioException ? qErr : DioException(requestOptions: queued.options, error: qErr));
          }
        }
        return;
      } catch (refreshErr) {
        AppLogger.error('Silent token refresh failed', refreshErr);
        await _secureStorage.clearAuthSession();
        while (_retryQueue.isNotEmpty) {
          _retryQueue.removeAt(0).handler.reject(err);
        }
        onSessionExpired?.call();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }
    return handler.next(err);
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options, String newAccessToken) {
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    return _refreshDio.fetch<dynamic>(options);
  }
}
