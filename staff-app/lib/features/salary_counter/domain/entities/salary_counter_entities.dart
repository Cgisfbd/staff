import 'package:equatable/equatable.dart';

/// 11-Month Academic Session (April to February) matching Web ERP's SalaryCounterTab.tsx.
const List<String> kAcademicMonths = [
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
  'January',
  'February',
];

/// Salary deduction item per month (e.g. Leave, Cut)
class SalaryDeductionEntity extends Equatable {
  final String month;
  final double amount;
  final String reason;

  const SalaryDeductionEntity({
    required this.month,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object?> get props => [month, amount, reason];
}

/// Official Salary Payment Voucher matching Web ERP.
class SalaryReceiptEntity extends Equatable {
  final String id;
  final String receiptNo;
  final String teacherId;
  final String academicYear;
  final List<String> months;
  final double amountPerMonth;
  final List<SalaryDeductionEntity> deductions;
  final double totalAmount;
  final String paymentDate;
  final String paymentMode; // 'Bank Transfer' | 'Cash' | 'Cheque' | 'UPI'
  final String? transactionRef;
  final DateTime createdAt;

  const SalaryReceiptEntity({
    required this.id,
    required this.receiptNo,
    required this.teacherId,
    required this.academicYear,
    required this.months,
    required this.amountPerMonth,
    required this.deductions,
    required this.totalAmount,
    required this.paymentDate,
    required this.paymentMode,
    this.transactionRef,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        receiptNo,
        teacherId,
        academicYear,
        months,
        amountPerMonth,
        deductions,
        totalAmount,
        paymentDate,
        paymentMode,
        transactionRef,
        createdAt,
      ];
}

/// Faculty member with salary contract and bank details.
class FacultySalaryRecordEntity extends Equatable {
  final String id;
  final String name;
  final String? nameUrdu;
  final String? fatherName;
  final String? fatherNameUrdu;
  final String phone;
  final String designation;
  final String residenceStatus; // 'Hostel Resident' | 'Day Scholar' | 'Online Virtual'
  final double monthlySalary;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final bool isActive;
  final String? photoUrl;

  const FacultySalaryRecordEntity({
    required this.id,
    required this.name,
    this.nameUrdu,
    this.fatherName,
    this.fatherNameUrdu,
    required this.phone,
    required this.designation,
    required this.residenceStatus,
    required this.monthlySalary,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.isActive = true,
    this.photoUrl,
  });

  double get annualBudget => monthlySalary * 11; // 11-Month target

  @override
  List<Object?> get props => [
        id,
        name,
        nameUrdu,
        fatherName,
        fatherNameUrdu,
        phone,
        designation,
        residenceStatus,
        monthlySalary,
        bankName,
        accountNumber,
        ifscCode,
        isActive,
        photoUrl,
      ];
}

/// Institutional Aggregate Stats matching Web ERP.
class InstitutionalSalaryStatsEntity extends Equatable {
  final double totalAnnualBudget;
  final double totalPaidAmount;
  final double totalDeductions;
  final double totalDueAmount;
  final int totalDueTeachers;
  final double totalRemaining;
  final int completionRate;
  final int totalStaff;

  const InstitutionalSalaryStatsEntity({
    required this.totalAnnualBudget,
    required this.totalPaidAmount,
    required this.totalDeductions,
    required this.totalDueAmount,
    required this.totalDueTeachers,
    required this.totalRemaining,
    required this.completionRate,
    required this.totalStaff,
  });

  @override
  List<Object?> get props => [
        totalAnnualBudget,
        totalPaidAmount,
        totalDeductions,
        totalDueAmount,
        totalDueTeachers,
        totalRemaining,
        completionRate,
        totalStaff,
      ];
}
