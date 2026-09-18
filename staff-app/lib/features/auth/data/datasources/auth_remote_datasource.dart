import 'dart:convert';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/utils/app_logger.dart';
import 'package:staff_app/features/auth/data/models/user_model.dart';
import 'package:staff_app/features/auth/domain/entities/login_response_entity.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseEntity> login({
    required String username,
    required String password,
  });

  Future<UserModel> verify2fa({
    required String tempToken,
    required String otp,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  @override
  Future<LoginResponseEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final responseBody = response.data ?? {};
      final rawUserData = responseBody['data'] as Map<String, dynamic>? ?? {};

      // 1. Check if 2FA verification challenge is required
      if (rawUserData['requires2fa'] == true) {
        final tempToken = rawUserData['tempToken']?.toString();
        AppLogger.info('2FA required for user $username. Transitioning to 2FA challenge.');
        return LoginResponseEntity(
          requires2fa: true,
          tempToken: tempToken,
          username: username,
        );
      }

      // 2. Extract and persist tokens & profile
      await _extractAndSaveTokens(response, rawUserData);
      await _secureStorage.setUserProfile(jsonEncode(rawUserData));

      AppLogger.info('Staff member authenticated successfully: $username');
      return LoginResponseEntity(
        user: UserModel.fromJson(rawUserData),
        requires2fa: false,
      );
    } catch (e, st) {
      AppLogger.error('AuthRemoteDataSource login failed', e, st);
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Authentication failed: $e');
    }
  }

  @override
  Future<UserModel> verify2fa({
    required String tempToken,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/v1/auth/login/2fa',
        data: {
          'tempToken': tempToken,
          'otp': otp,
        },
      );

      final responseBody = response.data ?? {};
      final rawUserData = responseBody['data'] as Map<String, dynamic>? ?? {};

      await _extractAndSaveTokens(response, rawUserData);
      await _secureStorage.setUserProfile(jsonEncode(rawUserData));

      AppLogger.info('2FA TOTP code verified successfully.');
      return UserModel.fromJson(rawUserData);
    } catch (e, st) {
      AppLogger.error('AuthRemoteDataSource 2FA verification failed', e, st);
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: '2FA verification failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.info('Sending backend logout request to /v1/auth/logout...');
      final response = await _apiClient.post<dynamic>('/v1/auth/logout');
      AppLogger.info('Backend session revoked successfully: ${response.statusCode}');
    } catch (e) {
      AppLogger.warn('Backend logout request encountered an issue: $e');
    } finally {
      await _secureStorage.clearAuthSession();
    }
  }

  Future<void> _extractAndSaveTokens(
    dynamic response,
    Map<String, dynamic> rawUserData,
  ) async {
    // 1. Extract tokens from JSON payload if present
    final tokenMap = (rawUserData['tokens'] as Map<String, dynamic>?) ?? rawUserData;
    final accessToken = tokenMap['accessToken']?.toString();
    final refreshToken = tokenMap['refreshToken']?.toString();
    if (accessToken != null && accessToken.isNotEmpty) await _secureStorage.setAccessToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) await _secureStorage.setRefreshToken(refreshToken);

    // 2. Extract tokens from HTTP Set-Cookie headers
    final dynamic rawHeaders = response?.headers;
    final List<String>? setCookieHeaders = rawHeaders != null ? (rawHeaders['set-cookie'] as List<String>?) : null;
    if (setCookieHeaders != null) {
      for (final cookie in setCookieHeaders) {
        if (cookie.contains('access_token=')) {
          final part = cookie.split(';').firstWhere((String s) => s.trim().startsWith('access_token='));
          final token = part.split('=').last.trim();
          if (token.isNotEmpty) await _secureStorage.setAccessToken(token);
        }
        if (cookie.contains('refresh_token=')) {
          final part = cookie.split(';').firstWhere((String s) => s.trim().startsWith('refresh_token='));
          final token = part.split('=').last.trim();
          if (token.isNotEmpty) await _secureStorage.setRefreshToken(token);
        }
      }
    }
  }
}
