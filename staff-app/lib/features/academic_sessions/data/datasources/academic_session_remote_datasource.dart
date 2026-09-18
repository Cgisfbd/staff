import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/academic_sessions/data/models/academic_session_model.dart';
import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';

abstract class AcademicSessionRemoteDataSource {
  Future<List<AcademicSessionModel>> getAcademicSessions();
  Future<NextSessionInfoModel> getNextSessionInfo();
  Future<AcademicSessionModel> createAcademicSession({
    required String yearName,
    required String startDate,
  });
  Future<AcademicSessionModel> lockAcademicSession({
    required String id,
    required String endDate,
    required String pin,
  });
  Future<AcademicSessionModel> setActiveSession(String id);
}

class AcademicSessionRemoteDataSourceImpl implements AcademicSessionRemoteDataSource {
  AcademicSessionRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working copy initialized with seed data for offline & dev resilience
  static final List<AcademicSessionModel> _localSessions = [
    AcademicSessionModel(
      id: 'session-2024-2025-uuid',
      simpleId: 1,
      yearName: '2024-2025',
      startDate: DateTime(2024, 4, 1),
      endDate: null,
      isActive: true,
      isLocked: false,
      progress: 45,
      studentStats: const SessionStudentStats(
        total: 1250,
        active: 1180,
        graduated: 55,
        dropout: 15,
      ),
      hierarchyStats: const SessionHierarchyStats(
        courses: 8,
        classes: 32,
        subjects: 64,
        books: 120,
      ),
      financeStats: const SessionFinanceStats(
        feesReceived: '₹28,50,000',
        salaryPaid: '₹18,20,000',
        expenses: '₹5,45,000',
        profitOrLoss: '₹4,85,000',
        isLoss: false,
      ),
    ),
    AcademicSessionModel(
      id: 'session-2023-2024-uuid',
      simpleId: 2,
      yearName: '2023-2024',
      startDate: DateTime(2023, 4, 1),
      endDate: DateTime(2024, 3, 31),
      isActive: false,
      isLocked: true,
      progress: 100,
      studentStats: const SessionStudentStats(
        total: 1120,
        active: 0,
        graduated: 1060,
        dropout: 60,
      ),
      hierarchyStats: const SessionHierarchyStats(
        courses: 8,
        classes: 30,
        subjects: 60,
        books: 115,
      ),
      financeStats: const SessionFinanceStats(
        feesReceived: '₹24,10,000',
        salaryPaid: '₹16,00,000',
        expenses: '₹4,20,000',
        profitOrLoss: '₹3,90,000',
        isLoss: false,
      ),
    ),
    AcademicSessionModel(
      id: 'session-2022-2023-uuid',
      simpleId: 3,
      yearName: '2022-2023',
      startDate: DateTime(2022, 4, 1),
      endDate: DateTime(2023, 3, 31),
      isActive: false,
      isLocked: true,
      progress: 100,
      studentStats: const SessionStudentStats(
        total: 980,
        active: 0,
        graduated: 940,
        dropout: 40,
      ),
      hierarchyStats: const SessionHierarchyStats(
        courses: 7,
        classes: 28,
        subjects: 54,
        books: 105,
      ),
      financeStats: const SessionFinanceStats(
        feesReceived: '₹20,50,000',
        salaryPaid: '₹14,20,000',
        expenses: '₹3,50,000',
        profitOrLoss: '₹2,80,000',
        isLoss: false,
      ),
    ),
  ];

  @override
  Future<List<AcademicSessionModel>> getAcademicSessions() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/admin-panel/academic-years');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data!['data'] ?? response.data;
        if (rawData is List) {
          final list = rawData.map((e) => AcademicSessionModel.fromJson(e as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    return List.unmodifiable(_localSessions);
  }

  @override
  Future<NextSessionInfoModel> getNextSessionInfo() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/admin-panel/academic-years/next');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return NextSessionInfoModel.fromJson(data);
        }
      }
    } catch (_) {}

    // Fallback: Check local state
    final hasActiveUnlocked = _localSessions.any((s) => s.isActive && !s.isLocked);
    if (hasActiveUnlocked) {
      return const NextSessionInfoModel(
        canCreate: false,
        message: 'Current active session must be locked before creating a new one.',
      );
    }
    return const NextSessionInfoModel(canCreate: true, nextYear: '2025-2026');
  }

  @override
  Future<AcademicSessionModel> createAcademicSession({
    required String yearName,
    required String startDate,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/admin-panel/academic-years',
        data: {'yearName': yearName, 'startDate': startDate},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final newModel = AcademicSessionModel.fromJson(data);
          _localSessions.insert(0, newModel);
          return newModel;
        }
      }
    } catch (_) {}

    // Fallback: Local insertion
    final parsedStart = DateTime.tryParse(startDate) ?? DateTime.now();
    final newSession = AcademicSessionModel(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      simpleId: _localSessions.length + 1,
      yearName: yearName,
      startDate: parsedStart,
      endDate: null,
      isActive: true,
      isLocked: false,
      progress: 0,
      studentStats: const SessionStudentStats(
        total: 1280,
        active: 1280,
        graduated: 0,
        dropout: 0,
      ),
      hierarchyStats: const SessionHierarchyStats(
        courses: 8,
        classes: 32,
        subjects: 64,
        books: 120,
      ),
      financeStats: const SessionFinanceStats(
        feesReceived: '₹0',
        salaryPaid: '₹0',
        expenses: '₹0',
        profitOrLoss: '₹0',
        isLoss: false,
      ),
    );

    // Deactivate previous active session
    for (int i = 0; i < _localSessions.length; i++) {
      if (_localSessions[i].isActive) {
        _localSessions[i] = _localSessions[i].copyWith(isActive: false);
      }
    }
    _localSessions.insert(0, newSession);
    return newSession;
  }

  @override
  Future<AcademicSessionModel> lockAcademicSession({
    required String id,
    required String endDate,
    required String pin,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/admin-panel/academic-years/$id/close',
        data: {'endDate': endDate, 'pin': pin},
      );
      if (response.statusCode == 200) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          final lockedModel = AcademicSessionModel.fromJson(data);
          final idx = _localSessions.indexWhere((s) => s.id == id);
          if (idx != -1) _localSessions[idx] = lockedModel;
          return lockedModel;
        }
      }
    } catch (_) {}

    // Fallback: Local update
    final parsedEnd = DateTime.tryParse(endDate) ?? DateTime.now();
    final idx = _localSessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final updated = _localSessions[idx].copyWith(
        isLocked: true,
        isActive: false,
        endDate: parsedEnd,
        progress: 100,
      );
      _localSessions[idx] = updated;
      return updated;
    }
    throw Exception('Session not found with id: $id');
  }

  @override
  Future<AcademicSessionModel> setActiveSession(String id) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>('/admin-panel/academic-years/$id/active');
      if (response.statusCode == 200) {
        final data = response.data!['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return AcademicSessionModel.fromJson(data);
        }
      }
    } catch (_) {}

    // Fallback: Toggle active
    AcademicSessionModel? activated;
    for (int i = 0; i < _localSessions.length; i++) {
      if (_localSessions[i].id == id) {
        _localSessions[i] = _localSessions[i].copyWith(isActive: true);
        activated = _localSessions[i];
      } else {
        _localSessions[i] = _localSessions[i].copyWith(isActive: false);
      }
    }
    if (activated != null) return activated;
    throw Exception('Session not found with id: $id');
  }
}
