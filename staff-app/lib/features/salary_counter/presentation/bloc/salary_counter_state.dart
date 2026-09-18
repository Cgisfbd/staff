import 'package:equatable/equatable.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

class TeacherDuesInfo {
  final int paidMonthsCount;
  final double paidAmount;
  final double deductions;
  final int dueCount;
  final double dueAmount;
  final double annualBudget;
  final double annualRemaining;
  final bool isFullyCleared;

  const TeacherDuesInfo({
    required this.paidMonthsCount,
    required this.paidAmount,
    required this.deductions,
    required this.dueCount,
    required this.dueAmount,
    required this.annualBudget,
    required this.annualRemaining,
    required this.isFullyCleared,
  });
}

class SalaryCounterState extends Equatable {
  final bool isDetailMode;
  final InstitutionalSalaryStatsEntity? stats;
  final List<FacultySalaryRecordEntity> facultyList;
  final String searchQuery;
  final String residenceFilter; // 'ALL' | 'DUE' | 'HOSTEL' | 'DAY_SCHOLAR'
  final FacultySalaryRecordEntity? selectedTeacher;
  final List<SalaryReceiptEntity> teacherReceipts;
  final List<String> selectedMonths;
  final Map<String, SalaryDeductionEntity> deductionsMap;
  final String paymentMode;
  final String paymentDate;
  final String transactionRef;
  final SalaryReceiptEntity? generatedReceipt;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const SalaryCounterState({
    this.isDetailMode = false,
    this.stats,
    this.facultyList = const [],
    this.searchQuery = '',
    this.residenceFilter = 'ALL',
    this.selectedTeacher,
    this.teacherReceipts = const [],
    this.selectedMonths = const [],
    this.deductionsMap = const {},
    this.paymentMode = 'Bank Transfer',
    this.paymentDate = '',
    this.transactionRef = '',
    this.generatedReceipt,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  Set<String> get paidMonthsSet {
    final set = <String>{};
    for (final r in teacherReceipts) {
      set.addAll(r.months);
    }
    return set;
  }

  double get currentGrossAmount {
    if (selectedTeacher == null) return 0.0;
    return selectedTeacher!.monthlySalary * selectedMonths.length;
  }

  double get currentTotalDeductions {
    double sum = 0.0;
    for (final m in selectedMonths) {
      sum += deductionsMap[m]?.amount ?? 0.0;
    }
    return sum;
  }

  double get currentNetPayable {
    final net = currentGrossAmount - currentTotalDeductions;
    return net > 0 ? net : 0.0;
  }

  TeacherDuesInfo getTeacherDuesInfo(FacultySalaryRecordEntity teacher, List<SalaryReceiptEntity> receipts) {
    final paidMonths = <String>{};
    double paidAmount = 0.0;
    double deductions = 0.0;

    for (final r in receipts) {
      paidMonths.addAll(r.months);
      paidAmount += r.totalAmount;
      for (final d in r.deductions) {
        deductions += d.amount;
      }
    }

    const currentPassedMonthIdx = 4; // August
    final passedCount = currentPassedMonthIdx + 1;
    final dueCount = (passedCount - paidMonths.length) > 0 ? (passedCount - paidMonths.length) : 0;
    final dueAmount = dueCount * teacher.monthlySalary;
    final annualBudget = teacher.monthlySalary * 11;
    final annualRemaining = (annualBudget - paidAmount) > 0 ? (annualBudget - paidAmount) : 0.0;

    return TeacherDuesInfo(
      paidMonthsCount: paidMonths.length,
      paidAmount: paidAmount,
      deductions: deductions,
      dueCount: dueCount,
      dueAmount: dueAmount,
      annualBudget: annualBudget,
      annualRemaining: annualRemaining,
      isFullyCleared: dueCount == 0,
    );
  }

  List<FacultySalaryRecordEntity> get filteredFacultyList {
    return facultyList.where((t) {
      final q = searchQuery.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          (t.nameUrdu != null && t.nameUrdu!.contains(q)) ||
          t.designation.toLowerCase().contains(q) ||
          t.phone.contains(q);

      final isHostel = t.residenceStatus.toLowerCase().contains('hostel');
      final isDay = t.residenceStatus.toLowerCase().contains('day');

      bool matchCategory = true;
      if (residenceFilter == 'HOSTEL') matchCategory = isHostel;
      if (residenceFilter == 'DAY_SCHOLAR') matchCategory = isDay;

      return matchSearch && matchCategory;
    }).toList();
  }

  SalaryCounterState copyWith({
    bool? isDetailMode,
    InstitutionalSalaryStatsEntity? stats,
    List<FacultySalaryRecordEntity>? facultyList,
    String? searchQuery,
    String? residenceFilter,
    FacultySalaryRecordEntity? selectedTeacher,
    List<SalaryReceiptEntity>? teacherReceipts,
    List<String>? selectedMonths,
    Map<String, SalaryDeductionEntity>? deductionsMap,
    String? paymentMode,
    String? paymentDate,
    String? transactionRef,
    SalaryReceiptEntity? generatedReceipt,
    bool clearGeneratedReceipt = false,
    bool clearSelectedTeacher = false,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return SalaryCounterState(
      isDetailMode: isDetailMode ?? this.isDetailMode,
      stats: stats ?? this.stats,
      facultyList: facultyList ?? this.facultyList,
      searchQuery: searchQuery ?? this.searchQuery,
      residenceFilter: residenceFilter ?? this.residenceFilter,
      selectedTeacher: clearSelectedTeacher ? null : (selectedTeacher ?? this.selectedTeacher),
      teacherReceipts: teacherReceipts ?? this.teacherReceipts,
      selectedMonths: selectedMonths ?? this.selectedMonths,
      deductionsMap: deductionsMap ?? this.deductionsMap,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionRef: transactionRef ?? this.transactionRef,
      generatedReceipt: clearGeneratedReceipt ? null : (generatedReceipt ?? this.generatedReceipt),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isDetailMode,
        stats,
        facultyList,
        searchQuery,
        residenceFilter,
        selectedTeacher,
        teacherReceipts,
        selectedMonths,
        deductionsMap,
        paymentMode,
        paymentDate,
        transactionRef,
        generatedReceipt,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
