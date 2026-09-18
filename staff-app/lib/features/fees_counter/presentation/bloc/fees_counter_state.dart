import 'package:equatable/equatable.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

enum FeesCounterLevel {
  courses, // Level 1
  classes, // Level 2
  students, // Level 3
  studentProfile, // Level 4
}

class FeesCounterState extends Equatable {
  final FeesCounterLevel currentLevel;
  final FeesKpiEntity? kpi;
  final List<FeesCourseSummaryEntity> courses;
  final List<FeesClassSummaryEntity> classes;
  final List<StudentFeeRecordEntity> students;
  final FeesCourseSummaryEntity? selectedCourse;
  final FeesClassSummaryEntity? selectedClass;
  final StudentFeeRecordEntity? selectedStudent;
  final String searchQuery;
  final List<String> selectedMonths;
  final double concessionAmount;
  final List<FeePaymentRecordEntity> studentPaymentsHistory;
  final FeePaymentRecordEntity? generatedReceipt;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const FeesCounterState({
    this.currentLevel = FeesCounterLevel.courses,
    this.kpi,
    this.courses = const [],
    this.classes = const [],
    this.students = const [],
    this.selectedCourse,
    this.selectedClass,
    this.selectedStudent,
    this.searchQuery = '',
    this.selectedMonths = const [],
    this.concessionAmount = 0.0,
    this.studentPaymentsHistory = const [],
    this.generatedReceipt,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  // Derived financial math matching Web ERP:
  double get studentMonthlyRate {
    if (selectedStudent == null) return 0.0;
    return selectedStudent!.monthlyRate;
  }

  double get currentGrossAmount {
    return studentMonthlyRate * selectedMonths.length;
  }

  double get currentNetPayable {
    final net = currentGrossAmount - concessionAmount;
    return net > 0 ? net : 0.0;
  }

  List<StudentFeeRecordEntity> get filteredStudents {
    if (searchQuery.trim().isEmpty) return students;
    final q = searchQuery.toLowerCase().trim();
    return students.where((s) {
      return s.fullNameEn.toLowerCase().contains(q) ||
          (s.nameUrdu != null && s.nameUrdu!.toLowerCase().contains(q)) ||
          s.mobile.contains(q) ||
          s.rollNo.toString().contains(q);
    }).toList();
  }

  List<FeesCourseSummaryEntity> get filteredCourses {
    if (searchQuery.trim().isEmpty) return courses;
    final q = searchQuery.toLowerCase().trim();
    return courses.where((c) {
      return c.nameEnglish.toLowerCase().contains(q) ||
          (c.nameUrdu != null && c.nameUrdu!.toLowerCase().contains(q)) ||
          (c.code != null && c.code!.toLowerCase().contains(q));
    }).toList();
  }

  FeesCounterState copyWith({
    FeesCounterLevel? currentLevel,
    FeesKpiEntity? kpi,
    List<FeesCourseSummaryEntity>? courses,
    List<FeesClassSummaryEntity>? classes,
    List<StudentFeeRecordEntity>? students,
    FeesCourseSummaryEntity? selectedCourse,
    FeesClassSummaryEntity? selectedClass,
    StudentFeeRecordEntity? selectedStudent,
    String? searchQuery,
    List<String>? selectedMonths,
    double? concessionAmount,
    List<FeePaymentRecordEntity>? studentPaymentsHistory,
    FeePaymentRecordEntity? generatedReceipt,
    bool clearGeneratedReceipt = false,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedStudent = false,
    bool clearSelectedClass = false,
    bool clearSelectedCourse = false,
  }) {
    return FeesCounterState(
      currentLevel: currentLevel ?? this.currentLevel,
      kpi: kpi ?? this.kpi,
      courses: courses ?? this.courses,
      classes: classes ?? this.classes,
      students: students ?? this.students,
      selectedCourse: clearSelectedCourse ? null : (selectedCourse ?? this.selectedCourse),
      selectedClass: clearSelectedClass ? null : (selectedClass ?? this.selectedClass),
      selectedStudent: clearSelectedStudent ? null : (selectedStudent ?? this.selectedStudent),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMonths: selectedMonths ?? this.selectedMonths,
      concessionAmount: concessionAmount ?? this.concessionAmount,
      studentPaymentsHistory: studentPaymentsHistory ?? this.studentPaymentsHistory,
      generatedReceipt: clearGeneratedReceipt ? null : (generatedReceipt ?? this.generatedReceipt),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentLevel,
        kpi,
        courses,
        classes,
        students,
        selectedCourse,
        selectedClass,
        selectedStudent,
        searchQuery,
        selectedMonths,
        concessionAmount,
        studentPaymentsHistory,
        generatedReceipt,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
