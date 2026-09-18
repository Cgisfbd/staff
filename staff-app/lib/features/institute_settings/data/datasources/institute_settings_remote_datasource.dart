import 'dart:io';
import 'package:dio/dio.dart';
import 'package:staff_app/core/error/exceptions.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:uuid/uuid.dart';

abstract class InstituteSettingsRemoteDataSource {
  Future<InstituteSettingsUiModel> getSettings({CancelToken? cancelToken});
  Future<InstituteSettingsUiModel> updateSettings(
    InstituteSettingsUiModel model, {
    CancelToken? cancelToken,
  });
  Future<String> uploadBrandingAsset({
    required File file,
    required String type,
    CancelToken? cancelToken,
  });
}

class InstituteSettingsRemoteDataSourceImpl implements InstituteSettingsRemoteDataSource {
  InstituteSettingsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<InstituteSettingsUiModel> getSettings({CancelToken? cancelToken}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/v1/institute/settings',
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data != null && data['data'] is Map<String, dynamic>) {
        return InstituteSettingsUiModel.fromJson(data['data'] as Map<String, dynamic>);
      } else if (data != null && data is Map<String, dynamic>) {
        return InstituteSettingsUiModel.fromJson(data);
      }
      throw ServerException(message: 'Invalid response format received for institute settings');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw NetworkException('Request was cancelled');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to load institute settings',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Unexpected error fetching institute settings: $e');
    }
  }

  @override
  Future<InstituteSettingsUiModel> updateSettings(
    InstituteSettingsUiModel model, {
    CancelToken? cancelToken,
  }) async {
    try {
      final payload = model.toJson();
      final idempotencyKey = const Uuid().v4();

      final response = await apiClient.patch<Map<String, dynamic>>(
        '/v1/institute/settings',
        data: payload,
        options: Options(
          headers: {
            'X-Idempotency-Key': idempotencyKey,
          },
        ),
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data != null && data['data'] is Map<String, dynamic>) {
        return InstituteSettingsUiModel.fromJson(data['data'] as Map<String, dynamic>);
      } else if (data != null && data is Map<String, dynamic>) {
        return InstituteSettingsUiModel.fromJson(data);
      }
      return model;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw NetworkException('Request was cancelled');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to update institute settings',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Unexpected error updating institute settings: $e');
    }
  }

  @override
  Future<String> uploadBrandingAsset({
    required File file,
    required String type,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await apiClient.post<Map<String, dynamic>>(
        '/v1/institute/settings/upload?type=$type',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data != null && data['data'] is Map && (data['data'] as Map)['url'] != null) {
        return (data['data'] as Map)['url'].toString();
      } else if (data != null && data['url'] != null) {
        return data['url'].toString();
      }
      throw ServerException(message: 'Asset uploaded but URL not returned by server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw NetworkException('Upload request was cancelled');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to upload branding asset',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Unexpected error uploading branding asset: $e');
    }
  }
}
