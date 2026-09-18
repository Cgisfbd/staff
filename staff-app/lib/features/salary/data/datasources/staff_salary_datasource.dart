import 'package:intl/intl.dart';
import 'package:staff_app/features/salary/domain/models/staff_salary_record.dart';

/// Datasource providing staff monthly salary history and overview metrics.
class StaffSalaryDatasource {
  const StaffSalaryDatasource();

  static const double standardBaseSalary = 25000.0;

  List<StaffSalaryRecord> getMonthlyHistory() {
    final now = DateTime.now();
    final List<StaffSalaryRecord> records = [];

    // Generate last 6 months of salary statements
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMMM yyyy').format(date);
      final monthShort = DateFormat('MMM').format(date);

      final isCurrentMonth = (i == 0);
      final isPending = isCurrentMonth && now.day < 5;

      // Realistic deductions: absent days, late arrivals, or advance recovery
      int absentDays = 0;
      double absentDeduction = 0.0;
      int lateDays = 0;
      double lateDeduction = 0.0;
      double advanceDeduction = 0.0;
      String notes = 'Full monthly salary disbursed.';

      if (i == 0) {
        // Current month: 1 absent (-₹1,000) + 3 late days (-₹300) + ₹1,500 advance recovery
        absentDays = 1;
        absentDeduction = 1000.0;
        lateDays = 3;
        lateDeduction = 300.0;
        advanceDeduction = 1500.0;
        notes = '1 day absent (-₹1,000), 3 days late (-₹300), advance recovery (-₹1,500)';
      } else if (i == 1) {
        // 1 month ago: 0 absent, 2 late days (-₹200), ₹1,500 advance recovery
        absentDays = 0;
        lateDays = 2;
        lateDeduction = 200.0;
        advanceDeduction = 1500.0;
        notes = '2 days late (-₹200) & advance recovery (-₹1,500)';
      } else if (i == 2) {
        // 2 months ago: 2 absent days (-₹2,000), 1 late day (-₹100)
        absentDays = 2;
        absentDeduction = 2000.0;
        lateDays = 1;
        lateDeduction = 100.0;
        notes = '2 days absent (-₹2,000) & 1 day late arrival (-₹100)';
      } else if (i == 4) {
        // 4 months ago: 1 absent day (-₹1,000), 2 late days (-₹200)
        absentDays = 1;
        absentDeduction = 1000.0;
        lateDays = 2;
        lateDeduction = 200.0;
        notes = '1 day emergency absence (-₹1,000) & 2 days late (-₹200)';
      }

      final status = isPending ? 'PENDING' : 'PAID';
      final paymentDate = isPending ? 'Expected by 05 $monthShort ${date.year}' : '05 $monthShort ${date.year}';
      final paymentMode = (i % 2 == 0) ? 'Bank Transfer (UPI)' : 'Cash Payment';
      final receiptNo = isPending ? null : 'RCP-${date.year}-${date.month.toString().padLeft(2, '0')}-0${80 + i * 11}';

      records.add(StaffSalaryRecord(
        id: 'sal_${date.year}_${date.month}',
        month: date.month,
        year: date.year,
        monthName: monthName,
        baseSalary: standardBaseSalary,
        absentDays: absentDays,
        absentDeduction: absentDeduction,
        lateDays: lateDays,
        lateDeduction: lateDeduction,
        advanceDeduction: advanceDeduction,
        status: status,
        paymentDate: paymentDate,
        paymentMode: paymentMode,
        receiptNo: receiptNo,
        paidBy: (paymentMode == 'Cash Payment') ? 'Office Cashier (Maulana Ibrahim)' : 'Direct Institutional Account',
        notes: notes,
      ));
    }

    return records;
  }

  SalaryOverview getOverview() {
    final history = getMonthlyHistory();
    double paidTotal = 0.0;
    double pendingTotal = 0.0;
    double deductionsTotal = 0.0;
    int absentTotal = 0;
    int lateTotal = 0;

    for (final r in history) {
      deductionsTotal += r.totalDeductions;
      absentTotal += r.absentDays;
      lateTotal += r.lateDays;
      if (r.status == 'PAID') {
        paidTotal += r.netSalary;
      } else if (r.status == 'PENDING') {
        pendingTotal += r.netSalary;
      }
    }

    // Estimate for upcoming month assuming full attendance
    const upcomingEstimate = standardBaseSalary;

    return SalaryOverview(
      totalPaid: paidTotal,
      totalPending: pendingTotal,
      totalDeductions: deductionsTotal,
      upcomingEstimate: upcomingEstimate,
      baseSalary: standardBaseSalary,
      totalAbsentDays: absentTotal,
      totalLateDays: lateTotal,
    );
  }
}
