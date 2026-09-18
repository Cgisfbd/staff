import 'package:equatable/equatable.dart';

/// Pure domain entity representing an institutional academic session
class AcademicSessionEntity extends Equatable {
  const AcademicSessionEntity({
    required this.id,
    required this.simpleId,
    required this.yearName,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isLocked,
    required this.progress,
    required this.studentStats,
    required this.hierarchyStats,
    required this.financeStats,
  });

  final String id;
  final int simpleId;
  final String yearName;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isLocked;
  final int progress;
  final SessionStudentStats studentStats;
  final SessionHierarchyStats hierarchyStats;
  final SessionFinanceStats financeStats;

  @override
  List<Object?> get props => [
        id,
        simpleId,
        yearName,
        startDate,
        endDate,
        isActive,
        isLocked,
        progress,
        studentStats,
        hierarchyStats,
        financeStats,
      ];
}

class SessionStudentStats extends Equatable {
  const SessionStudentStats({
    required this.total,
    required this.active,
    required this.graduated,
    required this.dropout,
  });

  final int total;
  final int active;
  final int graduated;
  final int dropout;

  @override
  List<Object?> get props => [total, active, graduated, dropout];
}

class SessionHierarchyStats extends Equatable {
  const SessionHierarchyStats({
    required this.courses,
    required this.classes,
    required this.subjects,
    required this.books,
  });

  final int courses;
  final int classes;
  final int subjects;
  final int books;

  @override
  List<Object?> get props => [courses, classes, subjects, books];
}

class SessionFinanceStats extends Equatable {
  const SessionFinanceStats({
    required this.feesReceived,
    required this.salaryPaid,
    required this.expenses,
    required this.profitOrLoss,
    required this.isLoss,
  });

  final String feesReceived;
  final String salaryPaid;
  final String expenses;
  final String profitOrLoss;
  final bool isLoss;

  @override
  List<Object?> get props => [feesReceived, salaryPaid, expenses, profitOrLoss, isLoss];
}

class NextSessionInfoEntity extends Equatable {
  const NextSessionInfoEntity({
    required this.canCreate,
    this.nextYear,
    this.message,
  });

  final bool canCreate;
  final String? nextYear;
  final String? message;

  @override
  List<Object?> get props => [canCreate, nextYear, message];
}
