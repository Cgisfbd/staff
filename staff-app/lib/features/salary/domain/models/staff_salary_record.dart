/// Domain model for Teacher / Staff Salary Record & Monthly Disbursement.
/// Strictly reflecting the real institutional model: fixed base salary with
/// deductions only for absent days (loss of pay) or advance recovery.
class StaffSalaryRecord {
  const StaffSalaryRecord({
    required this.id,
    required this.month,
    required this.year,
    required this.monthName,
    required this.baseSalary,
    required this.absentDays,
    required this.absentDeduction,
    required this.lateDays,
    required this.lateDeduction,
    required this.advanceDeduction,
    required this.status,
    this.paymentDate,
    required this.paymentMode,
    this.receiptNo,
    this.paidBy,
    this.notes,
  });

  final String id;
  final int month;
  final int year;
  final String monthName;
  final double baseSalary;
  final int absentDays;
  final double absentDeduction;
  final int lateDays;
  final double lateDeduction;
  final double advanceDeduction;
  final String status; // 'PAID', 'PENDING', 'UPCOMING'
  final String? paymentDate;
  final String paymentMode; // 'Cash Payment', 'Bank Transfer (UPI)', 'Cheque'
  final String? receiptNo;
  final String? paidBy;
  final String? notes;

  double get totalDeductions => absentDeduction + lateDeduction + advanceDeduction;
  double get netSalary => (baseSalary - totalDeductions).clamp(0.0, double.infinity);
}

/// Aggregated salary metrics for the top overview card.
class SalaryOverview {
  const SalaryOverview({
    required this.totalPaid,
    required this.totalPending,
    required this.totalDeductions,
    required this.upcomingEstimate,
    required this.baseSalary,
    this.totalAbsentDays = 0,
    this.totalLateDays = 0,
  });

  final double totalPaid;
  final double totalPending;
  final double totalDeductions;
  final double upcomingEstimate;
  final double baseSalary;
  final int totalAbsentDays;
  final int totalLateDays;

  double get annualSalary => baseSalary * 12;
  double get totalYearToDate => totalPaid + totalPending;
}

