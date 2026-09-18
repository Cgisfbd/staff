import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

class FeePaymentRecordModel extends FeePaymentRecordEntity {
  const FeePaymentRecordModel({
    required super.id,
    required super.receiptNo,
    required super.createdAt,
    required super.monthsPaid,
    required super.grossAmount,
    required super.concessionAmount,
    required super.amountPaid,
    required super.feeType,
    required super.type,
    required super.collector,
    super.notes,
  });

  factory FeePaymentRecordModel.fromJson(Map<String, dynamic> json) {
    return FeePaymentRecordModel(
      id: json['id']?.toString() ?? '',
      receiptNo: json['receiptNo']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      monthsPaid: (json['monthsPaid'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0.0,
      concessionAmount: (json['concessionAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      feeType: json['feeType']?.toString() ?? 'Tuition Only',
      type: json['type']?.toString() ?? 'DEPOSIT',
      collector: json['collector']?.toString() ?? 'Accounts Desk',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptNo': receiptNo,
      'createdAt': createdAt.toIso8601String(),
      'monthsPaid': monthsPaid,
      'grossAmount': grossAmount,
      'concessionAmount': concessionAmount,
      'amountPaid': amountPaid,
      'feeType': feeType,
      'type': type,
      'collector': collector,
      if (notes != null) 'notes': notes,
    };
  }
}

class StudentFeeRecordModel extends StudentFeeRecordEntity {
  const StudentFeeRecordModel({
    required super.id,
    required super.fullNameEn,
    super.nameUrdu,
    super.fatherNameEn,
    super.fatherNameUrdu,
    required super.rollNo,
    required super.mobile,
    required super.hostelFacility,
    required super.courseId,
    required super.courseName,
    required super.classId,
    required super.className,
    required super.tuitionFee,
    super.hostelFee = 0.0,
    required super.monthStatusMap,
    super.photoUrl,
  });

  factory StudentFeeRecordModel.fromJson(Map<String, dynamic> json) {
    final statusMapRaw = json['monthStatusMap'] as Map<String, dynamic>? ?? {};
    final Map<String, MonthStatusType> parsedStatusMap = {};
    for (final entry in statusMapRaw.entries) {
      final val = entry.value.toString().toUpperCase();
      if (val == 'PAID') {
        parsedStatusMap[entry.key] = MonthStatusType.paid;
      } else if (val == 'WAIVED') {
        parsedStatusMap[entry.key] = MonthStatusType.waived;
      } else if (val == 'PENDING') {
        parsedStatusMap[entry.key] = MonthStatusType.pending;
      } else {
        parsedStatusMap[entry.key] = MonthStatusType.upcoming;
      }
    }

    return StudentFeeRecordModel(
      id: json['id']?.toString() ?? '',
      fullNameEn: json['fullNameEn']?.toString() ?? 'Student',
      nameUrdu: json['nameUrdu']?.toString(),
      fatherNameEn: json['fatherNameEn']?.toString(),
      fatherNameUrdu: json['fatherNameUrdu']?.toString(),
      rollNo: (json['rollNo'] as num?)?.toInt() ?? 1,
      mobile: json['mobile']?.toString() ?? '',
      hostelFacility: json['hostelFacility']?.toString() ?? 'No',
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      tuitionFee: (json['tuitionFee'] as num?)?.toDouble() ?? 500.0,
      hostelFee: (json['hostelFee'] as num?)?.toDouble() ?? 1000.0,
      monthStatusMap: parsedStatusMap,
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullNameEn': fullNameEn,
      if (nameUrdu != null) 'nameUrdu': nameUrdu,
      if (fatherNameEn != null) 'fatherNameEn': fatherNameEn,
      if (fatherNameUrdu != null) 'fatherNameUrdu': fatherNameUrdu,
      'rollNo': rollNo,
      'mobile': mobile,
      'hostelFacility': hostelFacility,
      'courseId': courseId,
      'courseName': courseName,
      'classId': classId,
      'className': className,
      'tuitionFee': tuitionFee,
      'hostelFee': hostelFee,
      'monthStatusMap': monthStatusMap.map((k, v) => MapEntry(k, v.name.toUpperCase())),
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}

class FeesKpiModel extends FeesKpiEntity {
  const FeesKpiModel({
    required super.annualProjected,
    required super.totalCollected,
    required super.totalPending,
    required super.totalWaived,
    required super.totalStudents,
    required super.totalCourses,
    required super.totalClasses,
    required super.collectionRate,
  });

  factory FeesKpiModel.fromJson(Map<String, dynamic> json) {
    return FeesKpiModel(
      annualProjected: (json['annualProjected'] as num?)?.toDouble() ?? 0.0,
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
      totalPending: (json['totalPending'] as num?)?.toDouble() ?? 0.0,
      totalWaived: (json['totalWaived'] as num?)?.toDouble() ?? 0.0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      totalCourses: (json['totalCourses'] as num?)?.toInt() ?? 0,
      totalClasses: (json['totalClasses'] as num?)?.toInt() ?? 0,
      collectionRate: (json['collectionRate'] as num?)?.toInt() ?? 0,
    );
  }
}

class FeesCourseSummaryModel extends FeesCourseSummaryEntity {
  const FeesCourseSummaryModel({
    required super.id,
    required super.nameEnglish,
    super.nameUrdu,
    super.code,
    required super.classesCount,
    required super.studentsCount,
    required super.estMonthlyTuition,
    required super.isFullyConfigured,
  });

  factory FeesCourseSummaryModel.fromJson(Map<String, dynamic> json) {
    return FeesCourseSummaryModel(
      id: json['id']?.toString() ?? '',
      nameEnglish: json['nameEnglish']?.toString() ?? '',
      nameUrdu: json['nameUrdu']?.toString(),
      code: json['code']?.toString(),
      classesCount: (json['classesCount'] as num?)?.toInt() ?? 0,
      studentsCount: (json['studentsCount'] as num?)?.toInt() ?? 0,
      estMonthlyTuition: (json['estMonthlyTuition'] as num?)?.toDouble() ?? 0.0,
      isFullyConfigured: json['isFullyConfigured'] as bool? ?? true,
    );
  }
}

class FeesClassSummaryModel extends FeesClassSummaryEntity {
  const FeesClassSummaryModel({
    required super.id,
    required super.courseId,
    required super.nameEnglish,
    super.nameUrdu,
    required super.studentCount,
    required super.tuitionFee,
    super.hostelFee = 0.0,
    required super.totalMonthly,
    required super.collectionRate,
  });

  factory FeesClassSummaryModel.fromJson(Map<String, dynamic> json) {
    return FeesClassSummaryModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      nameEnglish: json['nameEnglish']?.toString() ?? '',
      nameUrdu: json['nameUrdu']?.toString(),
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      tuitionFee: (json['tuitionFee'] as num?)?.toDouble() ?? 0.0,
      hostelFee: (json['hostelFee'] as num?)?.toDouble() ?? 0.0,
      totalMonthly: (json['totalMonthly'] as num?)?.toDouble() ?? 0.0,
      collectionRate: (json['collectionRate'] as num?)?.toInt() ?? 0,
    );
  }
}
