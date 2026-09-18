import 'package:staff_app/features/academic_sessions/domain/entities/academic_session_entity.dart';

class AcademicSessionModel extends AcademicSessionEntity {
  const AcademicSessionModel({
    required super.id,
    required super.simpleId,
    required super.yearName,
    required super.startDate,
    super.endDate,
    required super.isActive,
    required super.isLocked,
    required super.progress,
    required super.studentStats,
    required super.hierarchyStats,
    required super.financeStats,
  });

  factory AcademicSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedStart;
    try {
      parsedStart = DateTime.parse(json['startDate']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      parsedStart = DateTime.now();
    }

    DateTime? parsedEnd;
    if (json['endDate'] != null) {
      try {
        parsedEnd = DateTime.parse(json['endDate'].toString());
      } catch (_) {}
    }

    final rawStudents = json['studentStats'] as Map<String, dynamic>? ?? {};
    final studentStats = SessionStudentStats(
      total: rawStudents['total'] as int? ?? 1250,
      active: rawStudents['active'] as int? ?? 1180,
      graduated: rawStudents['graduated'] as int? ?? 55,
      dropout: rawStudents['dropout'] as int? ?? 15,
    );

    final rawHierarchy = json['hierarchyStats'] as Map<String, dynamic>? ?? {};
    final hierarchyStats = SessionHierarchyStats(
      courses: rawHierarchy['courses'] as int? ?? 8,
      classes: rawHierarchy['classes'] as int? ?? 32,
      subjects: rawHierarchy['subjects'] as int? ?? 64,
      books: rawHierarchy['books'] as int? ?? 120,
    );

    final rawFinance = json['financeStats'] as Map<String, dynamic>? ?? {};
    final profitOrLossStr = rawFinance['profitOrLoss']?.toString() ?? '₹4,85,000';
    final isLoss = profitOrLossStr.contains('-');

    final financeStats = SessionFinanceStats(
      feesReceived: rawFinance['feesReceived']?.toString() ?? '₹28,50,000',
      salaryPaid: rawFinance['salaryPaid']?.toString() ?? '₹18,20,000',
      expenses: rawFinance['expenses']?.toString() ?? '₹5,45,000',
      profitOrLoss: isLoss ? profitOrLossStr.replaceAll('-', '') : profitOrLossStr,
      isLoss: isLoss,
    );

    return AcademicSessionModel(
      id: json['id']?.toString() ?? '',
      simpleId: json['simpleId'] as int? ?? 1,
      yearName: json['yearName']?.toString() ?? '2024-2025',
      startDate: parsedStart,
      endDate: parsedEnd,
      isActive: json['isActive'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
      studentStats: studentStats,
      hierarchyStats: hierarchyStats,
      financeStats: financeStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simpleId': simpleId,
      'yearName': yearName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'isLocked': isLocked,
      'progress': progress,
      'studentStats': {
        'total': studentStats.total,
        'active': studentStats.active,
        'graduated': studentStats.graduated,
        'dropout': studentStats.dropout,
      },
      'hierarchyStats': {
        'courses': hierarchyStats.courses,
        'classes': hierarchyStats.classes,
        'subjects': hierarchyStats.subjects,
        'books': hierarchyStats.books,
      },
      'financeStats': {
        'feesReceived': financeStats.feesReceived,
        'salaryPaid': financeStats.salaryPaid,
        'expenses': financeStats.expenses,
        'profitOrLoss': financeStats.profitOrLoss,
        'isLoss': financeStats.isLoss,
      },
    };
  }

  AcademicSessionModel copyWith({
    String? id,
    int? simpleId,
    String? yearName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isLocked,
    int? progress,
    SessionStudentStats? studentStats,
    SessionHierarchyStats? hierarchyStats,
    SessionFinanceStats? financeStats,
  }) {
    return AcademicSessionModel(
      id: id ?? this.id,
      simpleId: simpleId ?? this.simpleId,
      yearName: yearName ?? this.yearName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
      progress: progress ?? this.progress,
      studentStats: studentStats ?? this.studentStats,
      hierarchyStats: hierarchyStats ?? this.hierarchyStats,
      financeStats: financeStats ?? this.financeStats,
    );
  }
}

class NextSessionInfoModel extends NextSessionInfoEntity {
  const NextSessionInfoModel({
    required super.canCreate,
    super.nextYear,
    super.message,
  });

  factory NextSessionInfoModel.fromJson(Map<String, dynamic> json) {
    return NextSessionInfoModel(
      canCreate: json['canCreate'] as bool? ?? true,
      nextYear: json['nextYear']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
