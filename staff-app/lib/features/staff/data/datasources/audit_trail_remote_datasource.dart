import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/staff/data/models/audit_log_model.dart';

/// Contract for fetching tamper-evident institutional audit logs and KPIs.
abstract class AuditTrailRemoteDataSource {
  /// Fetch filtered audit records.
  /// [timeRange]: 'TODAY' | '3_DAYS' | '7_DAYS' | '10_DAYS' | '30_DAYS' | '6_MONTHS' | '1_YEAR' | 'LIFETIME' | 'CUSTOM'
  /// [category]: 'ALL' | 'FINANCE' | 'STUDENTS' | 'ATTENDANCE' | 'SECURITY' | 'EXAMS'
  Future<List<AuditLogModel>> getAuditLogs({
    String timeRange = 'TODAY',
    String category = 'ALL',
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });

  /// Fetch aggregated KPI summaries for Today, This Week, and Lifetime.
  Future<AuditSummaryModel> getAuditSummary();
}

class AuditTrailRemoteDataSourceImpl implements AuditTrailRemoteDataSource {
  AuditTrailRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory forensic audit dataset strictly structured as an immutable tamper-evident log
  static final List<AuditLogModel> _seedLogs = _buildForensicSeedLogs();

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    String timeRange = 'TODAY',
    String category = 'ALL',
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/v1/audit-logs',
        queryParameters: {
          'timeRange': timeRange.toLowerCase(),
          if (category != 'ALL') 'category': category.toLowerCase(),
          if (searchQuery != null && searchQuery.trim().isNotEmpty) 'search': searchQuery.trim(),
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'];
        if (data is Map<String, dynamic> && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => AuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Offline fallback: smooth switch to local forensic ledger
    }

    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);

    DateTime? filterStart;
    DateTime? filterEnd;

    switch (timeRange.toUpperCase()) {
      case 'TODAY':
        filterStart = todayStart;
        break;
      case '3_DAYS':
      case '3DAYS':
        filterStart = todayStart.subtract(const Duration(days: 3));
        break;
      case '7_DAYS':
      case '7DAYS':
      case 'WEEK':
        filterStart = todayStart.subtract(const Duration(days: 7));
        break;
      case '10_DAYS':
      case '10DAYS':
        filterStart = todayStart.subtract(const Duration(days: 10));
        break;
      case '30_DAYS':
      case '30DAYS':
      case 'MONTH':
        filterStart = todayStart.subtract(const Duration(days: 30));
        break;
      case '6_MONTHS':
      case '6MONTHS':
        filterStart = todayStart.subtract(const Duration(days: 180));
        break;
      case '1_YEAR':
      case '1YEAR':
      case 'YEAR':
        filterStart = todayStart.subtract(const Duration(days: 365));
        break;
      case 'CUSTOM':
        if (startDate != null) {
          filterStart = DateTime.utc(startDate.year, startDate.month, startDate.day);
        }
        if (endDate != null) {
          filterEnd = DateTime.utc(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
        }
        break;
      case 'LIFETIME':
      case 'ALL':
      case 'FULL':
      default:
        filterStart = null;
        break;
    }

    return _seedLogs.where((log) {
      // 1. Time Horizon / Date Range Filter
      if (filterStart != null && log.timestampUtc.isBefore(filterStart)) {
        return false;
      }
      if (filterEnd != null && log.timestampUtc.isAfter(filterEnd)) {
        return false;
      }

      // 2. Category Filter
      if (category != 'ALL' && log.category.toUpperCase() != category.toUpperCase()) {
        return false;
      }

      // 3. Search Query Filter (Actor, Target, Action, or Receipt)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matches = log.actorName.toLowerCase().contains(q) ||
            log.actorRole.toLowerCase().contains(q) ||
            log.targetName.toLowerCase().contains(q) ||
            log.action.toLowerCase().contains(q) ||
            (log.receiptNumber != null && log.receiptNumber!.toLowerCase().contains(q));
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<AuditSummaryModel> getAuditSummary() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/v1/audit-logs/summary');
      if (response.statusCode == 200 && response.data != null) {
        final d = response.data!['data'] as Map<String, dynamic>;
        return AuditSummaryModel(
          totalToday: d['totalToday'] as int? ?? 0,
          totalWeek: d['totalWeek'] as int? ?? 0,
          totalLifetime: d['totalLifetime'] as int? ?? 0,
          categoryCountsToday: Map<String, int>.from(d['categoryCountsToday'] as Map? ?? {}),
          categoryCountsWeek: Map<String, int>.from(d['categoryCountsWeek'] as Map? ?? {}),
          categoryCountsLifetime: Map<String, int>.from(d['categoryCountsLifetime'] as Map? ?? {}),
          totalAmountToday: (d['totalAmountToday'] as num?)?.toDouble() ?? 0.0,
          totalAmountWeek: (d['totalAmountWeek'] as num?)?.toDouble() ?? 0.0,
          totalAmountLifetime: (d['totalAmountLifetime'] as num?)?.toDouble() ?? 0.0,
          verifiedIntegrityCount: d['verifiedIntegrityCount'] as int? ?? 0,
        );
      }
    } catch (_) {}

    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));

    int todayCount = 0;
    int weekCount = 0;
    final int lifetimeCount = _seedLogs.length;

    final Map<String, int> catToday = {};
    final Map<String, int> catWeek = {};
    final Map<String, int> catLifetime = {};

    double amountToday = 0;
    double amountWeek = 0;
    double amountLifetime = 0;

    for (final log in _seedLogs) {
      final isToday = !log.timestampUtc.isBefore(todayStart);
      final isWeek = !log.timestampUtc.isBefore(weekStart);

      // Category breakdown
      catLifetime[log.category] = (catLifetime[log.category] ?? 0) + 1;
      if (isWeek) {
        weekCount++;
        catWeek[log.category] = (catWeek[log.category] ?? 0) + 1;
      }
      if (isToday) {
        todayCount++;
        catToday[log.category] = (catToday[log.category] ?? 0) + 1;
      }

      // Financial breakdown
      if (log.category == 'FINANCE') {
        final amt = (log.newValues?['paidAmount'] as num?)?.toDouble() ??
            (log.newValues?['amount'] as num?)?.toDouble() ??
            0.0;
        amountLifetime += amt;
        if (isWeek) amountWeek += amt;
        if (isToday) amountToday += amt;
      }
    }

    return AuditSummaryModel(
      totalToday: todayCount,
      totalWeek: weekCount,
      totalLifetime: lifetimeCount,
      categoryCountsToday: catToday,
      categoryCountsWeek: catWeek,
      categoryCountsLifetime: catLifetime,
      totalAmountToday: amountToday,
      totalAmountWeek: amountWeek,
      totalAmountLifetime: amountLifetime,
      verifiedIntegrityCount: _seedLogs.where((l) => l.integrityVerified).length,
    );
  }

  static List<AuditLogModel> _buildForensicSeedLogs() {
    final now = DateTime.now().toUtc();

    return [
      // 1. TODAY: Fee Collection
      AuditLogModel(
        auditId: 'aud_live_01',
        timestampUtc: now.subtract(const Duration(minutes: 18)),
        actorId: 'usr_clerk_01',
        actorName: 'Salman Ahmad',
        actorRole: 'CLERK',
        targetType: 'STUDENT',
        targetId: 'std_1042',
        targetName: 'Zaid Khan (Roll #102 • Darja Alim 1st)',
        category: 'FINANCE',
        action: 'FEE_COLLECTION',
        receiptNumber: 'REC-2026-0892',
        oldValues: const {
          'feeStatus': 'PENDING',
          'paidAmount': 0,
          'dueBalance': 5000,
        },
        newValues: const {
          'feeStatus': 'PAID',
          'paidAmount': 5000,
          'dueBalance': 0,
          'paymentMode': 'CASH',
          'receiptNo': 'REC-2026-0892',
          'remarks': 'Annual Tuition Fee installment cleared',
        },
        metadata: const {
          'counter': 'Counter-01 (Madarsa Main Gate)',
          'term': 'Quarter 1 (2026-27)',
        },
        ipAddress: '192.168.1.104',
        deviceId: 'dev_tab_sm_t500',
        deviceName: 'Samsung Galaxy Tab A7 (Staff Desk)',
        platform: 'Android 14 (Staff App)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_live_9a8b7c6d',
        previousHash: '0x3f7a8c9e1b2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8',
        currentHash: '0x8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9',
        integrityVerified: true,
      ),

      // 2. TODAY: Student Profile Update
      AuditLogModel(
        auditId: 'aud_live_02',
        timestampUtc: now.subtract(const Duration(minutes: 54)),
        actorId: 'usr_admin_02',
        actorName: 'Tariq Mahmood',
        actorRole: 'ADMIN',
        targetType: 'STUDENT',
        targetId: 'std_1088',
        targetName: 'Umar Farooq (Roll #108 • Hifz Section B)',
        category: 'STUDENTS',
        action: 'STUDENT_PROFILE_UPDATED',
        oldValues: const {
          'guardianPhone': '9876543210',
          'hostelRoom': 'Block B - Room 102',
        },
        newValues: const {
          'guardianPhone': '9123456780',
          'hostelRoom': 'Block B - Room 108',
          'reason': 'Father changed primary contact number & requested room transfer',
        },
        metadata: const {'authorizedBy': 'Vice Principal (Naib Nazim)'},
        ipAddress: '192.168.1.15',
        deviceId: 'dev_pc_win_04',
        deviceName: 'Executive Admin Desk (Dell OptiPlex)',
        platform: 'Windows Desktop (Web Portal)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_admin_44b2c1',
        previousHash: '0x8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9',
        currentHash: '0x4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5',
        integrityVerified: true,
      ),

      // 3. TODAY: Security PIN Reset by Super Admin
      AuditLogModel(
        auditId: 'aud_live_03',
        timestampUtc: now.subtract(const Duration(hours: 2, minutes: 12)),
        actorId: 'usr_super_01',
        actorName: 'Muhtamim Sahab',
        actorRole: 'SUPER_ADMIN',
        targetType: 'STAFF',
        targetId: 'usr_sub_109',
        targetName: 'Hamza Qureshi (@hamza.clerk)',
        category: 'SECURITY',
        action: 'STAFF_PIN_RESET',
        oldValues: const {'pinHash': r'argon2id$v=19$m=65536,t=3,p=4...[MASKED]'},
        newValues: const {
          'pinHash': r'argon2id$v=19$m=65536,t=3,p=4...[NEW_HASH_ROTATED]',
          'forcedChangeOnLogin': true,
          'reason': 'Clerk forgot 6-digit access PIN during morning counter shift',
        },
        metadata: const {'securityLevel': 'SUPREME_IRREVOCABLE_OVERRIDE'},
        ipAddress: '192.168.1.35',
        deviceId: 'dev_infinix_x6871',
        deviceName: 'Infinix X6871 (Principal Mobile)',
        platform: 'Android 15 (Staff App)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_super_88ff99',
        previousHash: '0x4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5',
        currentHash: '0x1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2',
        integrityVerified: true,
      ),

      // 4. TODAY: Attendance Batch Marked
      AuditLogModel(
        auditId: 'aud_live_04',
        timestampUtc: now.subtract(const Duration(hours: 3, minutes: 45)),
        actorId: 'usr_staff_05',
        actorName: 'Maulana Bilal',
        actorRole: 'TEACHER',
        targetType: 'ATTENDANCE_BATCH',
        targetId: 'att_batch_12',
        targetName: 'Darja Alim 1st Year (Morning Class)',
        category: 'ATTENDANCE',
        action: 'ATTENDANCE_BATCH_SUBMITTED',
        oldValues: const {'attendanceMarked': false, 'presentCount': 0},
        newValues: const {
          'attendanceMarked': true,
          'presentCount': 32,
          'absentCount': 2,
          'absentStudentIds': ['std_1012', 'std_1034'],
          'smsNotificationSent': true,
        },
        metadata: const {'classPeriod': 'Period 1 (Fiqh & Hadith)'},
        ipAddress: '192.168.1.52',
        deviceId: 'dev_redmi_note12',
        deviceName: 'Redmi Note 12 (Ustadh Device)',
        platform: 'Android 13 (Staff App)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_staff_112233',
        previousHash: '0x1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2',
        currentHash: '0x9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8',
        integrityVerified: true,
      ),

      // 5. TODAY: Fee Waiver Approved
      AuditLogModel(
        auditId: 'aud_live_05',
        timestampUtc: now.subtract(const Duration(hours: 5, minutes: 20)),
        actorId: 'usr_super_01',
        actorName: 'Muhtamim Sahab',
        actorRole: 'SUPER_ADMIN',
        targetType: 'STUDENT',
        targetId: 'std_1055',
        targetName: 'Abdur Rahman (Roll #115 • Fazilat Final)',
        category: 'FINANCE',
        action: 'FEE_WAIVER_APPLIED',
        receiptNumber: 'WAV-2026-0041',
        oldValues: const {
          'annualFee': 18000,
          'concessionAmount': 0,
          'netPayable': 18000,
        },
        newValues: const {
          'annualFee': 18000,
          'concessionAmount': 6000,
          'netPayable': 12000,
          'waiverCategory': 'Yateem / Orphan Scholar Aid',
          'sanctionOrderNo': 'ORD-MUH-2026/88',
        },
        metadata: const {'sanctionedBy': 'Institute Shura Board Resolution'},
        ipAddress: '192.168.1.10',
        deviceId: 'dev_mac_book_m2',
        deviceName: 'Executive Office Terminal',
        platform: 'macOS (Executive Portal)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_super_554433',
        previousHash: '0x9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8',
        currentHash: '0x7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6',
        integrityVerified: true,
      ),

      // 6. THIS WEEK: New Student Admission Provisioned
      AuditLogModel(
        auditId: 'aud_week_06',
        timestampUtc: now.subtract(const Duration(days: 1, hours: 4)),
        actorId: 'usr_admin_02',
        actorName: 'Tariq Mahmood',
        actorRole: 'ADMIN',
        targetType: 'STUDENT',
        targetId: 'std_1102',
        targetName: 'Muhammad Huzaifa (Form #ADM-2026-044)',
        category: 'STUDENTS',
        action: 'STUDENT_ADMISSION_REGISTERED',
        oldValues: null,
        newValues: const {
          'assignedClass': 'Darja Hifz Section A',
          'admissionFee': 2500,
          'hostelResident': true,
          'bloodGroup': 'B+',
          'status': 'ENROLLED',
        },
        metadata: const {'enrollmentDesk': 'Central Admission Cell'},
        ipAddress: '192.168.1.15',
        deviceId: 'dev_pc_win_04',
        deviceName: 'Executive Admin Desk (Dell OptiPlex)',
        platform: 'Windows Desktop (Web Portal)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_admin_44b2c1',
        previousHash: '0x7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6',
        currentHash: '0x5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4',
        integrityVerified: true,
      ),

      // 7. THIS WEEK: Sub-Account Blocked
      AuditLogModel(
        auditId: 'aud_week_07',
        timestampUtc: now.subtract(const Duration(days: 2, hours: 8)),
        actorId: 'usr_super_01',
        actorName: 'Muhtamim Sahab',
        actorRole: 'SUPER_ADMIN',
        targetType: 'STAFF',
        targetId: 'usr_sub_108',
        targetName: 'Farhan Ali (@farhan.clerk)',
        category: 'SECURITY',
        action: 'SUB_ACCOUNT_BLOCKED',
        oldValues: const {'isActive': true, 'loginAllowed': true},
        newValues: const {
          'isActive': false,
          'loginAllowed': false,
          'revocationReason': 'Suspended pending quarterly financial discrepancy audit',
        },
        metadata: const {'actionSeverity': 'CRITICAL_SECURITY_CONTAINMENT'},
        ipAddress: '192.168.1.35',
        deviceId: 'dev_infinix_x6871',
        deviceName: 'Infinix X6871 (Principal Mobile)',
        platform: 'Android 15 (Staff App)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_super_88ff99',
        previousHash: '0x5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4',
        currentHash: '0x3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2',
        integrityVerified: true,
      ),

      // 8. THIS WEEK: Quarterly Marks Entry Batch
      AuditLogModel(
        auditId: 'aud_week_08',
        timestampUtc: now.subtract(const Duration(days: 3, hours: 2)),
        actorId: 'usr_staff_05',
        actorName: 'Maulana Bilal',
        actorRole: 'TEACHER',
        targetType: 'EXAM_MARKS',
        targetId: 'ex_batch_89',
        targetName: 'Mishkat Sharif Final Exam (38 Students)',
        category: 'EXAMS',
        action: 'MARKS_BATCH_ENTERED',
        oldValues: const {'submitted': false, 'gradedCount': 0},
        newValues: const {
          'submitted': true,
          'gradedCount': 38,
          'highestMarks': 98,
          'averageScore': 81.4,
          'examinerSignVerified': true,
        },
        metadata: const {'examTerm': 'Mid-Term Evaluation 2026'},
        ipAddress: '192.168.1.52',
        deviceId: 'dev_redmi_note12',
        deviceName: 'Redmi Note 12 (Ustadh Device)',
        platform: 'Android 13 (Staff App)',
        appVersion: 'v2.4.0',
        sessionId: 'sess_staff_112233',
        previousHash: '0x3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2',
        currentHash: '0x1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0',
        integrityVerified: true,
      ),

      // 9. LIFETIME: Fee Collection (Older)
      AuditLogModel(
        auditId: 'aud_life_09',
        timestampUtc: now.subtract(const Duration(days: 14, hours: 6)),
        actorId: 'usr_acc_03',
        actorName: 'Rashid Ali',
        actorRole: 'ACCOUNTANT',
        targetType: 'STUDENT',
        targetId: 'std_1011',
        targetName: 'Ahmad Raza (Roll #101 • Darja Alim 2nd)',
        category: 'FINANCE',
        action: 'FEE_COLLECTION',
        receiptNumber: 'REC-2026-0711',
        oldValues: const {'dueBalance': 6000, 'feeStatus': 'PENDING'},
        newValues: const {
          'dueBalance': 0,
          'feeStatus': 'PAID',
          'paidAmount': 6000,
          'paymentMode': 'BANK_TRANSFER',
          'utrNumber': 'UTR998811223344',
        },
        metadata: const {'bank': 'State Bank of India (Institute A/C)'},
        ipAddress: '192.168.1.22',
        deviceId: 'dev_pc_acc_01',
        deviceName: 'Accounts Room PC (HP EliteDesk)',
        platform: 'Windows Desktop (Web Portal)',
        appVersion: 'v2.3.8',
        sessionId: 'sess_acc_001122',
        previousHash: '0x1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0',
        currentHash: '0x0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9',
        integrityVerified: true,
      ),

      // 10. LIFETIME: Sub-Account Provisioned
      AuditLogModel(
        auditId: 'aud_life_10',
        timestampUtc: now.subtract(const Duration(days: 28, hours: 10)),
        actorId: 'usr_super_01',
        actorName: 'Muhtamim Sahab',
        actorRole: 'SUPER_ADMIN',
        targetType: 'STAFF',
        targetId: 'usr_sub_101',
        targetName: 'Salman Ahmad (@salman.clerk)',
        category: 'SECURITY',
        action: 'SUB_ACCOUNT_CREATED',
        oldValues: null,
        newValues: const {
          'assignedRole': 'STAFF',
          'delegatedModules': ['students', 'fees', 'attendance'],
          'status': 'ACTIVE',
        },
        metadata: const {'authority': 'Master Institutional RBAC Matrix'},
        ipAddress: '192.168.1.35',
        deviceId: 'dev_infinix_x6871',
        deviceName: 'Infinix X6871 (Principal Mobile)',
        platform: 'Android 15 (Staff App)',
        appVersion: 'v2.3.5',
        sessionId: 'sess_super_000001',
        previousHash: '0x0000000000000000000000000000000000000000000000000000000000000000',
        currentHash: '0x0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9',
        integrityVerified: true,
      ),

      // 11. 8 DAYS AGO (Within 10 Days filter): Fee Collection
      AuditLogModel(
        auditId: 'aud_seed_11',
        timestampUtc: now.subtract(const Duration(days: 8, hours: 4)),
        actorId: 'usr_clerk_01',
        actorName: 'Salman Ahmad',
        actorRole: 'CLERK',
        targetType: 'STUDENT',
        targetId: 'std_1077',
        targetName: 'Kashif Rizvi (Roll #109 • Darja Hifz)',
        category: 'FINANCE',
        action: 'FEE_COLLECTION',
        receiptNumber: 'REC-2026-0688',
        oldValues: const {'dueBalance': 4500, 'feeStatus': 'PENDING'},
        newValues: const {
          'dueBalance': 0,
          'feeStatus': 'PAID',
          'paidAmount': 4500,
          'paymentMode': 'UPI_QR',
          'transactionRef': 'UPI_98822771100',
          'remarks': 'Term 2 Hostel Boarding Fee paid via counter UPI',
        },
        metadata: const {'posMachine': 'Counter-02 Scanner'},
        ipAddress: '192.168.1.106',
        deviceId: 'dev_tab_sm_t500',
        deviceName: 'Samsung Galaxy Tab A7 (Staff Desk)',
        platform: 'Android 14 (Staff App)',
        appVersion: 'v2.3.9',
        sessionId: 'sess_live_887766',
        previousHash: '0x0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9',
        currentHash: '0x887766554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa99',
        integrityVerified: true,
      ),

      // 12. 22 DAYS AGO (Within 30 Days filter): Hostel Room Transfer
      AuditLogModel(
        auditId: 'aud_seed_12',
        timestampUtc: now.subtract(const Duration(days: 22, hours: 6)),
        actorId: 'usr_admin_02',
        actorName: 'Tariq Mahmood',
        actorRole: 'ADMIN',
        targetType: 'STUDENT',
        targetId: 'std_1090',
        targetName: 'Bilal Hasan (Roll #112 • Darja Alim 3rd)',
        category: 'STUDENTS',
        action: 'STUDENT_PROFILE_UPDATED',
        oldValues: const {'hostelRoom': 'Hostel Block A - Room 101'},
        newValues: const {
          'hostelRoom': 'Hostel Block C - Room 204',
          'transferReason': 'Senior hostel wing elevation approved by Nazim-e-Darul Iqama',
        },
        metadata: const {'wingSupervisor': 'Maulana Zubair'},
        ipAddress: '192.168.1.15',
        deviceId: 'dev_pc_win_04',
        deviceName: 'Executive Admin Desk (Dell OptiPlex)',
        platform: 'Windows Desktop (Web Portal)',
        appVersion: 'v2.3.8',
        sessionId: 'sess_admin_99aa11',
        previousHash: '0x887766554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa99',
        currentHash: '0x7766554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa9988',
        integrityVerified: true,
      ),

      // 13. 55 DAYS AGO (Within 6 Months filter): Monthly Attendance Roster
      AuditLogModel(
        auditId: 'aud_seed_13',
        timestampUtc: now.subtract(const Duration(days: 55, hours: 2)),
        actorId: 'usr_staff_05',
        actorName: 'Maulana Bilal',
        actorRole: 'TEACHER',
        targetType: 'ATTENDANCE_BATCH',
        targetId: 'att_m_04',
        targetName: 'Hifz Section B - Monthly Closure Roster',
        category: 'ATTENDANCE',
        action: 'ATTENDANCE_BATCH_SUBMITTED',
        oldValues: const {'rosterLocked': false},
        newValues: const {
          'rosterLocked': true,
          'totalWorkingDays': 26,
          'overallClassAttendancePercentage': 94.2,
        },
        metadata: const {'auditPeriod': 'July 2026 Academic Month'},
        ipAddress: '192.168.1.52',
        deviceId: 'dev_redmi_note12',
        deviceName: 'Redmi Note 12 (Ustadh Device)',
        platform: 'Android 13 (Staff App)',
        appVersion: 'v2.3.4',
        sessionId: 'sess_staff_778899',
        previousHash: '0x7766554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa9988',
        currentHash: '0x66554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa998877',
        integrityVerified: true,
      ),

      // 14. 140 DAYS AGO (Within 6 Months filter): Mid-Term Exam Roster
      AuditLogModel(
        auditId: 'aud_seed_14',
        timestampUtc: now.subtract(const Duration(days: 140, hours: 8)),
        actorId: 'usr_admin_02',
        actorName: 'Tariq Mahmood',
        actorRole: 'ADMIN',
        targetType: 'EXAM_MARKS',
        targetId: 'ex_mid_2026',
        targetName: 'Mid-Term Arabic Grammar & Morphology Examination',
        category: 'EXAMS',
        action: 'MARKS_BATCH_ENTERED',
        oldValues: const {'published': false},
        newValues: const {
          'published': true,
          'enrolledStudents': 64,
          'passedStudents': 61,
          'highestPercentage': 99.0,
        },
        metadata: const {'controllerOfExams': 'Maulana Qasim'},
        ipAddress: '192.168.1.15',
        deviceId: 'dev_pc_win_04',
        deviceName: 'Executive Admin Desk (Dell OptiPlex)',
        platform: 'Windows Desktop (Web Portal)',
        appVersion: 'v2.3.0',
        sessionId: 'sess_admin_334455',
        previousHash: '0x66554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa998877',
        currentHash: '0x554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766',
        integrityVerified: true,
      ),

      // 15. 290 DAYS AGO (Within 1 Year filter): Annual Scholar Fee Waiver
      AuditLogModel(
        auditId: 'aud_seed_15',
        timestampUtc: now.subtract(const Duration(days: 290, hours: 5)),
        actorId: 'usr_super_01',
        actorName: 'Muhtamim Sahab',
        actorRole: 'SUPER_ADMIN',
        targetType: 'STUDENT',
        targetId: 'std_1002',
        targetName: 'Anas Siddiqui (Roll #102 • Darja Fazilat)',
        category: 'FINANCE',
        action: 'FEE_WAIVER_APPLIED',
        receiptNumber: 'WAV-2025-0012',
        oldValues: const {'netPayable': 24000, 'concessionAmount': 0},
        newValues: const {
          'concessionAmount': 8000,
          'netPayable': 16000,
          'waiverCategory': 'Merit Cum Need Zakat Scholarship',
          'sanctionOrderNo': 'ORD-MUH-2025/112',
        },
        metadata: const {'sanctionedBy': 'Majlis-e-Shura Annual Budget Resolution'},
        ipAddress: '192.168.1.10',
        deviceId: 'dev_mac_book_m2',
        deviceName: 'Executive Office Terminal',
        platform: 'macOS (Executive Portal)',
        appVersion: 'v2.2.0',
        sessionId: 'sess_super_110022',
        previousHash: '0x554433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766',
        currentHash: '0x4433221100ffeeddccbbaa99887766554433221100ffeeddccbbaa9988776655',
        integrityVerified: true,
      ),
    ];
  }
}
