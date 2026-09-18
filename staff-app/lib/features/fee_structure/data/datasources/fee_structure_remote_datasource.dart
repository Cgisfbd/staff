import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/fee_structure/data/models/fee_structure_model.dart';

abstract class FeeStructureRemoteDataSource {
  Future<List<FeeStructureModel>> getFees({String? courseId});
  Future<FeeStructureModel?> getFeeByClass(String classId);
  Future<FeeStructureModel> createFee({
    required String classId,
    required String className,
    int? tuitionFee,
    int? hostelFee,
    int? admissionFeeHostel,
    int? admissionFeeNonHostel,
    int? admissionRenewalFee,
    int? examFee,
    int? onlineFee,
    int? onlineAdmissionFee,
  });
  Future<FeeStructureModel> updateFee({
    required String id,
    int? tuitionFee,
    int? hostelFee,
    int? admissionFeeHostel,
    int? admissionFeeNonHostel,
    int? admissionRenewalFee,
    int? examFee,
    int? onlineFee,
    int? onlineAdmissionFee,
  });
  Future<void> deleteFee(String id);
}

class FeeStructureRemoteDataSourceImpl implements FeeStructureRemoteDataSource {
  FeeStructureRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working copy for offline resilience & optimistic updates
  static final List<FeeStructureModel> _localFees =
      List.from(FeeStructureModel.mockFees);

  @override
  Future<List<FeeStructureModel>> getFees({String? courseId}) async {
    try {
      final endpoint = courseId != null && courseId.isNotEmpty && courseId != 'ALL'
          ? '/admin-panel/fees?courseId=$courseId'
          : '/admin-panel/fees';

      final response = await apiClient.get<Map<String, dynamic>>(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        if (rawData is List) {
          final list = rawData
              .map((e) => FeeStructureModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _localFees
            ..clear()
            ..addAll(list);
          return List.unmodifiable(_localFees);
        }
      }
    } catch (_) {}

    return List.unmodifiable(_localFees);
  }

  @override
  Future<FeeStructureModel?> getFeeByClass(String classId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/admin-panel/fees/$classId');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        if (rawData is Map<String, dynamic>) {
          return FeeStructureModel.fromJson(rawData);
        }
      }
    } catch (_) {}

    try {
      return _localFees.firstWhere((f) => f.classId == classId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FeeStructureModel> createFee({
    required String classId,
    required String className,
    int? tuitionFee,
    int? hostelFee,
    int? admissionFeeHostel,
    int? admissionFeeNonHostel,
    int? admissionRenewalFee,
    int? examFee,
    int? onlineFee,
    int? onlineAdmissionFee,
  }) async {
    final body = {
      'classId': classId,
      'className': className,
      'tuitionFee': tuitionFee ?? 0,
      'hostelFee': hostelFee ?? 0,
      'admissionFeeHostel': admissionFeeHostel ?? 0,
      'admissionFeeNonHostel': admissionFeeNonHostel ?? 0,
      'admissionRenewalFee': admissionRenewalFee ?? 0,
      'examFee': examFee ?? 0,
      'onlineFee': onlineFee ?? 0,
      'onlineAdmissionFee': onlineAdmissionFee ?? 0,
    };

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/admin-panel/fees',
        data: body,
      );

      if (response.statusCode == 201 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        final created = FeeStructureModel.fromJson(rawData as Map<String, dynamic>);
        _localFees.removeWhere((f) => f.classId == classId);
        _localFees.add(created);
        return created;
      }
    } catch (_) {}

    // Offline / fallback creation
    final fallback = FeeStructureModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      classId: classId,
      className: className,
      tuitionFee: tuitionFee ?? 0,
      hostelFee: hostelFee ?? 0,
      admissionFeeHostel: admissionFeeHostel ?? 0,
      admissionFeeNonHostel: admissionFeeNonHostel ?? 0,
      admissionRenewalFee: admissionRenewalFee ?? 0,
      examFee: examFee ?? 0,
      onlineFee: onlineFee ?? 0,
      onlineAdmissionFee: onlineAdmissionFee ?? 0,
    );
    _localFees.removeWhere((f) => f.classId == classId);
    _localFees.add(fallback);
    return fallback;
  }

  @override
  Future<FeeStructureModel> updateFee({
    required String id,
    int? tuitionFee,
    int? hostelFee,
    int? admissionFeeHostel,
    int? admissionFeeNonHostel,
    int? admissionRenewalFee,
    int? examFee,
    int? onlineFee,
    int? onlineAdmissionFee,
  }) async {
    final body = <String, dynamic>{};
    if (tuitionFee != null) body['tuitionFee'] = tuitionFee;
    if (hostelFee != null) body['hostelFee'] = hostelFee;
    if (admissionFeeHostel != null) body['admissionFeeHostel'] = admissionFeeHostel;
    if (admissionFeeNonHostel != null) body['admissionFeeNonHostel'] = admissionFeeNonHostel;
    if (admissionRenewalFee != null) body['admissionRenewalFee'] = admissionRenewalFee;
    if (examFee != null) body['examFee'] = examFee;
    if (onlineFee != null) body['onlineFee'] = onlineFee;
    if (onlineAdmissionFee != null) body['onlineAdmissionFee'] = onlineAdmissionFee;

    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '/admin-panel/fees/$id',
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        final updated = FeeStructureModel.fromJson(rawData as Map<String, dynamic>);
        final idx = _localFees.indexWhere((f) => f.id == id);
        if (idx != -1) {
          _localFees[idx] = updated;
        } else {
          _localFees.add(updated);
        }
        return updated;
      }
    } catch (_) {}

    final idx = _localFees.indexWhere((f) => f.id == id);
    if (idx != -1) {
      final existing = _localFees[idx];
      final updated = existing.copyWith(
        tuitionFee: tuitionFee ?? existing.tuitionFee,
        hostelFee: hostelFee ?? existing.hostelFee,
        admissionFeeHostel: admissionFeeHostel ?? existing.admissionFeeHostel,
        admissionFeeNonHostel: admissionFeeNonHostel ?? existing.admissionFeeNonHostel,
        admissionRenewalFee: admissionRenewalFee ?? existing.admissionRenewalFee,
        examFee: examFee ?? existing.examFee,
        onlineFee: onlineFee ?? existing.onlineFee,
        onlineAdmissionFee: onlineAdmissionFee ?? existing.onlineAdmissionFee,
      );
      _localFees[idx] = updated;
      return updated;
    }

    throw Exception('Fee structure not found');
  }

  @override
  Future<void> deleteFee(String id) async {
    try {
      await apiClient.delete<Map<String, dynamic>>(
        '/admin-panel/fees/$id',
        data: {'pin': '1234'},
      );
    } catch (_) {}
    _localFees.removeWhere((f) => f.id == id);
  }
}
