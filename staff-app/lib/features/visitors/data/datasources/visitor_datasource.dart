import 'package:staff_app/features/visitors/domain/models/visitor_pass_model.dart';

/// In-memory Production Datasource for Visitor Pass verification and visit deduction.
class VisitorDatasource {
  VisitorDatasource();

  static final List<VisitorPassEntity> _passes = [
    VisitorPassEntity(
      cardId: 'vis_001',
      cardNumber: 'VIS-2026-881',
      visitorName: 'Tariq Mahmood',
      visitorPhone: '+91 98765 43210',
      relation: 'father',
      cnicOrId: 'AADHAAR: **** 9081',
      studentId: 'stu_101',
      studentName: 'Mohammad Zaid',
      studentRollNo: '101',
      studentClass: 'Aalimiyat 1st Year (Section A)',
      hostelRoom: 'B-204 (Darul Quran)',
      totalAllowedVisits: 4,
      usedVisits: 1,
      remainingVisits: 3,
      status: VisitorPassStatus.active,
      lastVisitedAt: DateTime.now().subtract(const Duration(days: 12)),
      visitLogs: [
        VisitorLogEntry(
          id: 'log_seed_1',
          timestamp: DateTime.now().subtract(const Duration(days: 12)),
          deductedBy: 'Ustadh Ahmed (Gate Officer)',
          gateLocation: 'Main Campus Gate #1',
          visitNumber: 1,
          remarks: 'Monthly parent meeting',
        ),
      ],
    ),
    VisitorPassEntity(
      cardId: 'vis_002',
      cardNumber: 'VIS-2026-882',
      visitorName: 'Shabbir Ahmad',
      visitorPhone: '+91 97654 32109',
      relation: 'brother',
      cnicOrId: 'AADHAAR: **** 4412',
      studentId: 'stu_102',
      studentName: 'Abdullah Khan',
      studentRollNo: '102',
      studentClass: 'Aalimiyat 1st Year (Section A)',
      hostelRoom: 'B-108 (Darul Hadees)',
      totalAllowedVisits: 3,
      usedVisits: 2,
      remainingVisits: 1,
      status: VisitorPassStatus.active,
      lastVisitedAt: DateTime.now().subtract(const Duration(days: 5)),
      visitLogs: [
        VisitorLogEntry(
          id: 'log_seed_2',
          timestamp: DateTime.now().subtract(const Duration(days: 20)),
          deductedBy: 'Ustadh Bilal',
          gateLocation: 'Main Campus Gate #1',
          visitNumber: 1,
        ),
        VisitorLogEntry(
          id: 'log_seed_3',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          deductedBy: 'Ustadh Ahmed',
          gateLocation: 'Hostel Reception',
          visitNumber: 2,
          remarks: 'Medicine handover',
        ),
      ],
    ),
    VisitorPassEntity(
      cardId: 'vis_003',
      cardNumber: 'VIS-2026-883',
      visitorName: 'Rashid Ali Qasmi',
      visitorPhone: '+91 96543 21098',
      relation: 'uncle',
      cnicOrId: 'AADHAAR: **** 1198',
      studentId: 'stu_104',
      studentName: 'Umar Farooq',
      studentRollNo: '104',
      studentClass: 'Aalimiyat 1st Year (Section A)',
      hostelRoom: 'A-301 (Bab-us-Salam)',
      totalAllowedVisits: 2,
      usedVisits: 2,
      remainingVisits: 0,
      status: VisitorPassStatus.exhausted,
      lastVisitedAt: DateTime.now().subtract(const Duration(days: 2)),
      visitLogs: [
        VisitorLogEntry(
          id: 'log_seed_4',
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          deductedBy: 'Ustadh Ahmed',
          gateLocation: 'Main Campus Gate #1',
          visitNumber: 1,
        ),
        VisitorLogEntry(
          id: 'log_seed_5',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          deductedBy: 'Ustadh Tariq',
          gateLocation: 'Main Campus Gate #1',
          visitNumber: 2,
          remarks: 'Term limit reached',
        ),
      ],
    ),
    const VisitorPassEntity(
      cardId: 'vis_004',
      cardNumber: 'VIS-2026-884',
      visitorName: 'Zubair Ahmad Qasmi Sr.',
      visitorPhone: '+91 95432 10987',
      relation: 'guardian',
      cnicOrId: 'AADHAAR: **** 7731',
      studentId: 'stu_106',
      studentName: 'Bilal Ahmad',
      studentRollNo: '106',
      studentClass: 'Aalimiyat 1st Year (Section A)',
      hostelRoom: 'C-102 (Darul Hikmah)',
      totalAllowedVisits: 4,
      usedVisits: 0,
      remainingVisits: 4,
      status: VisitorPassStatus.active,
      visitLogs: [],
    ),
  ];

  static final List<VisitorPassEntity> _todayScanned = [];

  List<VisitorPassEntity> getAllPasses() => List.unmodifiable(_passes);

  List<VisitorPassEntity> getTodayScanned() => List.unmodifiable(_todayScanned);

  VisitorPassEntity? lookup(String query) {
    final clean = query.trim().toUpperCase();
    if (clean.isEmpty) return null;

    try {
      return _passes.firstWhere(
        (p) =>
            p.cardNumber.toUpperCase() == clean ||
            p.studentRollNo == clean ||
            p.cardId.toUpperCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  VisitorPassEntity? deductVisit(
    String cardId, {
    String? remarks,
    String staffName = 'Ustadh Ahmed (Gate Security)',
    String gateLocation = 'Main Campus Gate #1',
  }) {
    final index = _passes.indexWhere((p) => p.cardId == cardId);
    if (index == -1) return null;

    final current = _passes[index];
    if (current.remainingVisits <= 0) return null;

    final newRemaining = current.remainingVisits - 1;
    final newUsed = current.usedVisits + 1;
    final newStatus =
        newRemaining == 0 ? VisitorPassStatus.exhausted : VisitorPassStatus.active;

    final newLog = VisitorLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      deductedBy: staffName,
      gateLocation: gateLocation,
      visitNumber: newUsed,
      remarks: remarks,
    );

    final updated = current.copyWith(
      usedVisits: newUsed,
      remainingVisits: newRemaining,
      status: newStatus,
      lastVisitedAt: DateTime.now(),
      visitLogs: [newLog, ...current.visitLogs],
    );

    _passes[index] = updated;

    // Track in today's scanned roster
    _todayScanned.removeWhere((p) => p.cardId == cardId);
    _todayScanned.insert(0, updated);

    return updated;
  }
}
