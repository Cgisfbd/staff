import 'package:equatable/equatable.dart';

/// Month status in the 10-month academic ledger.
enum MonthStatusType {
  paid,
  pending,
  waived,
  upcoming,
}

/// Month descriptor matching Web ERP's finance.constants.ts (10 Months: Jan to Oct).
class AcademicMonthEntity extends Equatable {
  final String key;
  final String nameEn;
  final String shortEn;
  final int order;

  const AcademicMonthEntity({
    required this.key,
    required this.nameEn,
    required this.shortEn,
    required this.order,
  });

  @override
  List<Object?> get props => [key, nameEn, shortEn, order];
}

/// Exactly 10-Month Academic Session (Jan to Oct) matching Web ERP.
const List<AcademicMonthEntity> kCalendarMonths = [
  AcademicMonthEntity(key: 'jan', nameEn: 'January', shortEn: 'Jan', order: 1),
  AcademicMonthEntity(key: 'feb', nameEn: 'February', shortEn: 'Feb', order: 2),
  AcademicMonthEntity(key: 'mar', nameEn: 'March', shortEn: 'Mar', order: 3),
  AcademicMonthEntity(key: 'apr', nameEn: 'April', shortEn: 'Apr', order: 4),
  AcademicMonthEntity(key: 'may', nameEn: 'May', shortEn: 'May', order: 5),
  AcademicMonthEntity(key: 'jun', nameEn: 'June', shortEn: 'Jun', order: 6),
  AcademicMonthEntity(key: 'jul', nameEn: 'July', shortEn: 'Jul', order: 7),
  AcademicMonthEntity(key: 'aug', nameEn: 'August', shortEn: 'Aug', order: 8),
  AcademicMonthEntity(key: 'sep', nameEn: 'September', shortEn: 'Sep', order: 9),
  AcademicMonthEntity(key: 'oct', nameEn: 'October', shortEn: 'Oct', order: 10),
];

/// Student fee profile with bio and 10-month status lookup.
class StudentFeeRecordEntity extends Equatable {
  final String id;
  final String fullNameEn;
  final String? nameUrdu;
  final String? fatherNameEn;
  final String? fatherNameUrdu;
  final int rollNo;
  final String mobile;
  final String hostelFacility; // 'Yes' | 'No'
  final String courseId;
  final String courseName;
  final String classId;
  final String className;
  final double tuitionFee;
  final double hostelFee;
  final Map<String, MonthStatusType> monthStatusMap; // keyed by shortEn e.g. 'Jan'
  final String? photoUrl;

  const StudentFeeRecordEntity({
    required this.id,
    required this.fullNameEn,
    this.nameUrdu,
    this.fatherNameEn,
    this.fatherNameUrdu,
    required this.rollNo,
    required this.mobile,
    required this.hostelFacility,
    required this.courseId,
    required this.courseName,
    required this.classId,
    required this.className,
    required this.tuitionFee,
    this.hostelFee = 0.0,
    required this.monthStatusMap,
    this.photoUrl,
  });

  bool get isHostel => hostelFacility.toLowerCase() == 'yes';

  double get monthlyRate => tuitionFee + (isHostel ? hostelFee : 0.0);

  @override
  List<Object?> get props => [
        id,
        fullNameEn,
        nameUrdu,
        fatherNameEn,
        fatherNameUrdu,
        rollNo,
        mobile,
        hostelFacility,
        courseId,
        courseName,
        classId,
        className,
        tuitionFee,
        hostelFee,
        monthStatusMap,
        photoUrl,
      ];
}

/// Official Payment & Concession Receipt matching Web ERP.
class FeePaymentRecordEntity extends Equatable {
  final String id;
  final String receiptNo;
  final DateTime createdAt;
  final List<String> monthsPaid;
  final double grossAmount;
  final double concessionAmount;
  final double amountPaid;
  final String feeType;
  final String type; // 'DEPOSIT' | 'WAIVED'
  final String collector;
  final String? notes;

  const FeePaymentRecordEntity({
    required this.id,
    required this.receiptNo,
    required this.createdAt,
    required this.monthsPaid,
    required this.grossAmount,
    required this.concessionAmount,
    required this.amountPaid,
    required this.feeType,
    required this.type,
    required this.collector,
    this.notes,
  });

  bool get isWaived => type == 'WAIVED';

  @override
  List<Object?> get props => [
        id,
        receiptNo,
        createdAt,
        monthsPaid,
        grossAmount,
        concessionAmount,
        amountPaid,
        feeType,
        type,
        collector,
        notes,
      ];
}

/// Overall 6 KPIs matching Web ERP's FinanceKPICards.tsx.
class FeesKpiEntity extends Equatable {
  final double annualProjected;
  final double totalCollected;
  final double totalPending;
  final double totalWaived;
  final int totalStudents;
  final int totalCourses;
  final int totalClasses;
  final int collectionRate;

  const FeesKpiEntity({
    required this.annualProjected,
    required this.totalCollected,
    required this.totalPending,
    required this.totalWaived,
    required this.totalStudents,
    required this.totalCourses,
    required this.totalClasses,
    required this.collectionRate,
  });

  @override
  List<Object?> get props => [
        annualProjected,
        totalCollected,
        totalPending,
        totalWaived,
        totalStudents,
        totalCourses,
        totalClasses,
        collectionRate,
      ];
}

/// Course financial summary for Level 1 table.
class FeesCourseSummaryEntity extends Equatable {
  final String id;
  final String nameEnglish;
  final String? nameUrdu;
  final String? code;
  final int classesCount;
  final int studentsCount;
  final double estMonthlyTuition;
  final bool isFullyConfigured;

  const FeesCourseSummaryEntity({
    required this.id,
    required this.nameEnglish,
    this.nameUrdu,
    this.code,
    required this.classesCount,
    required this.studentsCount,
    required this.estMonthlyTuition,
    required this.isFullyConfigured,
  });

  double get totalExpected => estMonthlyTuition * studentsCount;
  double get totalCollected => totalExpected * 0.75;

  @override
  List<Object?> get props => [
        id,
        nameEnglish,
        nameUrdu,
        code,
        classesCount,
        studentsCount,
        estMonthlyTuition,
        isFullyConfigured,
      ];
}

/// Class financial summary for Level 2 table.
class FeesClassSummaryEntity extends Equatable {
  final String id;
  final String courseId;
  final String nameEnglish;
  final String? nameUrdu;
  final int studentCount;
  final double tuitionFee;
  final double hostelFee;
  final double totalMonthly;
  final int collectionRate;

  const FeesClassSummaryEntity({
    required this.id,
    required this.courseId,
    required this.nameEnglish,
    this.nameUrdu,
    required this.studentCount,
    required this.tuitionFee,
    this.hostelFee = 0.0,
    required this.totalMonthly,
    required this.collectionRate,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        nameEnglish,
        nameUrdu,
        studentCount,
        tuitionFee,
        hostelFee,
        totalMonthly,
        collectionRate,
      ];
}
