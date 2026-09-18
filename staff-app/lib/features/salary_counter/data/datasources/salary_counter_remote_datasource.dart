import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/salary_counter/data/models/salary_counter_models.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

abstract class SalaryCounterRemoteDataSource {
  Future<InstitutionalSalaryStatsModel> getInstitutionalStats();
  Future<List<FacultySalaryRecordModel>> getFacultyList();
  Future<List<SalaryReceiptModel>> getPaymentHistoryForFaculty(String teacherId);
  Future<SalaryReceiptModel> disburseSalary({
    required String teacherId,
    required String academicYear,
    required List<String> months,
    required double amountPerMonth,
    required List<SalaryDeductionEntity> deductions,
    required double totalAmount,
    required String paymentDate,
    required String paymentMode,
    String? transactionRef,
    String? idempotencyKey,
  });
}

class SalaryCounterRemoteDataSourceImpl implements SalaryCounterRemoteDataSource {
  final ApiClient _apiClient;

  SalaryCounterRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  ApiClient get apiClient => _apiClient;

  // In-memory payment ledger matching Web ERP
  static final Map<String, List<SalaryReceiptModel>> _salaryLedgerMap = {
    'st-1': [
      SalaryReceiptModel(
        id: 'rcpt-1',
        receiptNo: 'SAL-2627-0101',
        teacherId: 'st-1',
        academicYear: '2026-2027',
        months: const ['April', 'May', 'June', 'July'],
        amountPerMonth: 28000.0,
        deductions: const [],
        totalAmount: 112000.0,
        paymentDate: '2026-07-05',
        paymentMode: 'Bank Transfer',
        transactionRef: 'NEFT84920194',
        createdAt: DateTime(2026, 7, 5, 10, 0),
      ),
    ],
    'st-2': [
      SalaryReceiptModel(
        id: 'rcpt-2',
        receiptNo: 'SAL-2627-0102',
        teacherId: 'st-2',
        academicYear: '2026-2027',
        months: const ['April', 'May', 'June'],
        amountPerMonth: 22000.0,
        deductions: const [
          SalaryDeductionModel(month: 'June', amount: 500.0, reason: '1 Day Leave Deduction'),
        ],
        totalAmount: 65500.0,
        paymentDate: '2026-06-05',
        paymentMode: 'Bank Transfer',
        transactionRef: 'NEFT84920195',
        createdAt: DateTime(2026, 6, 5, 10, 0),
      ),
    ],
    'st-3': [
      SalaryReceiptModel(
        id: 'rcpt-3',
        receiptNo: 'SAL-2627-0103',
        teacherId: 'st-3',
        academicYear: '2026-2027',
        months: const ['April', 'May', 'June', 'July'],
        amountPerMonth: 26000.0,
        deductions: const [],
        totalAmount: 104000.0,
        paymentDate: '2026-07-05',
        paymentMode: 'Bank Transfer',
        transactionRef: 'NEFT84920196',
        createdAt: DateTime(2026, 7, 5, 10, 0),
      ),
    ],
  };

  static final List<FacultySalaryRecordModel> _facultySeed = const [
    FacultySalaryRecordModel(
      id: 'st-1',
      name: 'Mohammad Tariq Jameel',
      nameUrdu: 'محمد طارق جمیل',
      fatherName: 'Abdul Qadir',
      fatherNameUrdu: 'عبد القادر',
      phone: '9876543210',
      designation: 'Academic Dean',
      residenceStatus: 'Hostel Resident',
      monthlySalary: 28000.0,
      bankName: 'State Bank of India',
      accountNumber: '38472910394',
      ifscCode: 'SBIN0000712',
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    ),
    FacultySalaryRecordModel(
      id: 'st-2',
      name: 'Qari Mohammad Bilal',
      nameUrdu: 'قاری محمد بلال',
      fatherName: 'Shamsul Huda',
      fatherNameUrdu: 'شمس الہدیٰ',
      phone: '9812345678',
      designation: 'Qari & Hifz In-Charge',
      residenceStatus: 'Day Scholar',
      monthlySalary: 22000.0,
      bankName: 'Punjab National Bank',
      accountNumber: '56123019847',
      ifscCode: 'PUNB0123400',
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    FacultySalaryRecordModel(
      id: 'st-3',
      name: 'Mufti Salman Qasmi',
      nameUrdu: 'مفتی سلمان قاسمی',
      fatherName: 'Ziaur Rahman',
      fatherNameUrdu: 'ضیاء الرحمن',
      phone: '9823456789',
      designation: 'Mufti / Lecturer',
      residenceStatus: 'Hostel Resident',
      monthlySalary: 26000.0,
      bankName: 'HDFC Bank',
      accountNumber: '50100239481',
      ifscCode: 'HDFC0001234',
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ),
    FacultySalaryRecordModel(
      id: 'st-4',
      name: 'Maulana Zaid Usmani',
      nameUrdu: 'مولانا زید عثمانی',
      fatherName: 'Irfan Usmani',
      fatherNameUrdu: 'عرفان عثمانی',
      phone: '9834567890',
      designation: 'Senior Teacher',
      residenceStatus: 'Online Virtual',
      monthlySalary: 20000.0,
      bankName: 'State Bank of India',
      accountNumber: '39120491823',
      ifscCode: 'SBIN0000712',
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    ),
    FacultySalaryRecordModel(
      id: 'st-5',
      name: 'Hafiz Zubair Ahmad',
      nameUrdu: 'حافظ زبیر احمد',
      fatherName: 'Masood Ahmad',
      fatherNameUrdu: 'مسعود احمد',
      phone: '9845678901',
      designation: 'Assistant Teacher',
      residenceStatus: 'Day Scholar',
      monthlySalary: 18000.0,
      bankName: 'Bank of Baroda',
      accountNumber: '29481029384',
      ifscCode: 'BARB0SAMBHA',
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
    ),
  ];

  @override
  Future<InstitutionalSalaryStatsModel> getInstitutionalStats() async {
    double totalBudget = 0.0;
    double totalPaid = 0.0;
    double totalDeductions = 0.0;
    double totalDue = 0.0;
    int dueTeachers = 0;

    const currentPassedMonthIdx = 4; // August

    for (final teacher in _facultySeed) {
      final annualBudget = teacher.monthlySalary * 11;
      totalBudget += annualBudget;

      final receipts = _salaryLedgerMap[teacher.id] ?? [];
      final paidMonths = <String>{};
      for (final r in receipts) {
        paidMonths.addAll(r.months);
        totalPaid += r.totalAmount;
        for (final d in r.deductions) {
          totalDeductions += d.amount;
        }
      }

      final passedCount = currentPassedMonthIdx + 1;
      final dueCount = (passedCount - paidMonths.length) > 0 ? (passedCount - paidMonths.length) : 0;
      final teacherDue = dueCount * teacher.monthlySalary;
      totalDue += teacherDue;
      if (dueCount > 0) dueTeachers++;
    }

    final totalRemaining = (totalBudget - totalPaid) > 0 ? (totalBudget - totalPaid) : 0.0;
    final completionRate = totalBudget > 0 ? ((totalPaid / totalBudget) * 100).round() : 0;

    return InstitutionalSalaryStatsModel(
      totalAnnualBudget: totalBudget,
      totalPaidAmount: totalPaid,
      totalDeductions: totalDeductions,
      totalDueAmount: totalDue,
      totalDueTeachers: dueTeachers,
      totalRemaining: totalRemaining,
      completionRate: completionRate,
      totalStaff: _facultySeed.length,
    );
  }

  @override
  Future<List<FacultySalaryRecordModel>> getFacultyList() async {
    return _facultySeed;
  }

  @override
  Future<List<SalaryReceiptModel>> getPaymentHistoryForFaculty(String teacherId) async {
    return _salaryLedgerMap[teacherId] ?? [];
  }

  @override
  Future<SalaryReceiptModel> disburseSalary({
    required String teacherId,
    required String academicYear,
    required List<String> months,
    required double amountPerMonth,
    required List<SalaryDeductionEntity> deductions,
    required double totalAmount,
    required String paymentDate,
    required String paymentMode,
    String? transactionRef,
    String? idempotencyKey,
  }) async {
    final receiptNo = 'SAL-2627-0${100 + DateTime.now().millisecond % 900}';
    final newReceipt = SalaryReceiptModel(
      id: 'rcpt-${DateTime.now().millisecondsSinceEpoch}',
      receiptNo: receiptNo,
      teacherId: teacherId,
      academicYear: academicYear,
      months: List.of(months),
      amountPerMonth: amountPerMonth,
      deductions: deductions
          .map((d) => SalaryDeductionModel(month: d.month, amount: d.amount, reason: d.reason))
          .toList(),
      totalAmount: totalAmount,
      paymentDate: paymentDate,
      paymentMode: paymentMode,
      transactionRef: paymentMode == 'Cash'
          ? null
          : (transactionRef ?? 'TXN${10000000 + DateTime.now().microsecond % 90000000}'),
      createdAt: DateTime.now(),
    );

    final list = _salaryLedgerMap[teacherId] ?? [];
    _salaryLedgerMap[teacherId] = [newReceipt, ...list];

    return newReceipt;
  }
}
