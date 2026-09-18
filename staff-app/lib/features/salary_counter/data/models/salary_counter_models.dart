import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

class SalaryDeductionModel extends SalaryDeductionEntity {
  const SalaryDeductionModel({
    required super.month,
    required super.amount,
    required super.reason,
  });

  factory SalaryDeductionModel.fromJson(Map<String, dynamic> json) {
    return SalaryDeductionModel(
      month: json['month']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? 'Leave Deduction',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'amount': amount,
      'reason': reason,
    };
  }
}

class SalaryReceiptModel extends SalaryReceiptEntity {
  const SalaryReceiptModel({
    required super.id,
    required super.receiptNo,
    required super.teacherId,
    required super.academicYear,
    required super.months,
    required super.amountPerMonth,
    required super.deductions,
    required super.totalAmount,
    required super.paymentDate,
    required super.paymentMode,
    super.transactionRef,
    required super.createdAt,
  });

  factory SalaryReceiptModel.fromJson(Map<String, dynamic> json) {
    final deductionsRaw = json['deductions'] as List<dynamic>? ?? [];
    return SalaryReceiptModel(
      id: json['id']?.toString() ?? '',
      receiptNo: json['receiptNo']?.toString() ?? '',
      teacherId: json['teacherId']?.toString() ?? '',
      academicYear: json['academicYear']?.toString() ?? '2026-2027',
      months: (json['months'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      amountPerMonth: (json['amountPerMonth'] as num?)?.toDouble() ?? 0.0,
      deductions: deductionsRaw.map((d) => SalaryDeductionModel.fromJson(d as Map<String, dynamic>)).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['paymentDate']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? 'Bank Transfer',
      transactionRef: json['transactionRef']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptNo': receiptNo,
      'teacherId': teacherId,
      'academicYear': academicYear,
      'months': months,
      'amountPerMonth': amountPerMonth,
      'deductions': deductions.map((d) => (d as SalaryDeductionModel).toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentDate': paymentDate,
      'paymentMode': paymentMode,
      if (transactionRef != null) 'transactionRef': transactionRef,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FacultySalaryRecordModel extends FacultySalaryRecordEntity {
  const FacultySalaryRecordModel({
    required super.id,
    required super.name,
    super.nameUrdu,
    super.fatherName,
    super.fatherNameUrdu,
    required super.phone,
    required super.designation,
    required super.residenceStatus,
    required super.monthlySalary,
    super.bankName,
    super.accountNumber,
    super.ifscCode,
    super.isActive = true,
    super.photoUrl,
  });

  factory FacultySalaryRecordModel.fromJson(Map<String, dynamic> json) {
    return FacultySalaryRecordModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Faculty Member',
      nameUrdu: json['nameUrdu']?.toString(),
      fatherName: json['fatherName']?.toString(),
      fatherNameUrdu: json['fatherNameUrdu']?.toString(),
      phone: json['phone']?.toString() ?? '',
      designation: json['designation']?.toString() ?? 'Teacher',
      residenceStatus: json['residenceStatus']?.toString() ?? 'Hostel Resident',
      monthlySalary: (json['monthlySalary'] as num?)?.toDouble() ?? 20000.0,
      bankName: json['bankName']?.toString() ?? 'State Bank of India',
      accountNumber: json['accountNumber']?.toString() ?? '38472910394',
      ifscCode: json['ifscCode']?.toString() ?? 'SBIN0000712',
      isActive: json['isActive'] as bool? ?? true,
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (nameUrdu != null) 'nameUrdu': nameUrdu,
      if (fatherName != null) 'fatherName': fatherName,
      if (fatherNameUrdu != null) 'fatherNameUrdu': fatherNameUrdu,
      'phone': phone,
      'designation': designation,
      'residenceStatus': residenceStatus,
      'monthlySalary': monthlySalary,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'isActive': isActive,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}

class InstitutionalSalaryStatsModel extends InstitutionalSalaryStatsEntity {
  const InstitutionalSalaryStatsModel({
    required super.totalAnnualBudget,
    required super.totalPaidAmount,
    required super.totalDeductions,
    required super.totalDueAmount,
    required super.totalDueTeachers,
    required super.totalRemaining,
    required super.completionRate,
    required super.totalStaff,
  });

  factory InstitutionalSalaryStatsModel.fromJson(Map<String, dynamic> json) {
    return InstitutionalSalaryStatsModel(
      totalAnnualBudget: (json['totalAnnualBudget'] as num?)?.toDouble() ?? 0.0,
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      totalDueAmount: (json['totalDueAmount'] as num?)?.toDouble() ?? 0.0,
      totalDueTeachers: (json['totalDueTeachers'] as num?)?.toInt() ?? 0,
      totalRemaining: (json['totalRemaining'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completionRate'] as num?)?.toInt() ?? 0,
      totalStaff: (json['totalStaff'] as num?)?.toInt() ?? 0,
    );
  }
}
