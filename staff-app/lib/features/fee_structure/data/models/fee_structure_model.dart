import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';

class FeeStructureModel extends FeeStructureEntity {
  const FeeStructureModel({
    required super.id,
    required super.classId,
    required super.className,
    super.courseId,
    super.courseName,
    super.simpleId = 1,
    super.tuitionFee = 0,
    super.hostelFee = 0,
    super.admissionFeeHostel = 0,
    super.admissionFeeNonHostel = 0,
    super.admissionRenewalFee = 0,
    super.examFee = 0,
    super.onlineFee = 0,
    super.onlineAdmissionFee = 0,
    super.createdAt,
    super.updatedAt,
  });

  factory FeeStructureModel.fromJson(Map<String, dynamic> json) {
    return FeeStructureModel(
      id: (json['id'] ?? '').toString(),
      classId: (json['classId'] ?? json['class_id'] ?? '').toString(),
      className: (json['className'] ?? json['class_name'] ?? 'Unnamed Class').toString(),
      courseId: (json['courseId'] ?? json['course_id'])?.toString(),
      courseName: (json['courseName'] ?? json['course_name'])?.toString(),
      simpleId: _parseInt(json['simpleId'] ?? json['simple_id'] ?? 1),
      tuitionFee: _parseInt(json['tuitionFee'] ?? json['tuition_fee']),
      hostelFee: _parseInt(json['hostelFee'] ?? json['hostel_fee']),
      admissionFeeHostel: _parseInt(json['admissionFeeHostel'] ?? json['admission_fee_hostel']),
      admissionFeeNonHostel: _parseInt(json['admissionFeeNonHostel'] ?? json['admission_fee_non_hostel']),
      admissionRenewalFee: _parseInt(json['admissionRenewalFee'] ?? json['admission_renewal_fee']),
      examFee: _parseInt(json['examFee'] ?? json['exam_fee']),
      onlineFee: _parseInt(json['onlineFee'] ?? json['online_fee']),
      onlineAdmissionFee: _parseInt(json['onlineAdmissionFee'] ?? json['online_admission_fee']),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['created_at']).toString())
          : null,
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.tryParse((json['updatedAt'] ?? json['updated_at']).toString())
          : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'tuitionFee': tuitionFee,
      'hostelFee': hostelFee,
      'admissionFeeHostel': admissionFeeHostel,
      'admissionFeeNonHostel': admissionFeeNonHostel,
      'admissionRenewalFee': admissionRenewalFee,
      'examFee': examFee,
      'onlineFee': onlineFee,
      'onlineAdmissionFee': onlineAdmissionFee,
    };
  }

  FeeStructureModel copyWith({
    String? id,
    String? classId,
    String? className,
    String? courseId,
    String? courseName,
    int? simpleId,
    int? tuitionFee,
    int? hostelFee,
    int? admissionFeeHostel,
    int? admissionFeeNonHostel,
    int? admissionRenewalFee,
    int? examFee,
    int? onlineFee,
    int? onlineAdmissionFee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeeStructureModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      simpleId: simpleId ?? this.simpleId,
      tuitionFee: tuitionFee ?? this.tuitionFee,
      hostelFee: hostelFee ?? this.hostelFee,
      admissionFeeHostel: admissionFeeHostel ?? this.admissionFeeHostel,
      admissionFeeNonHostel:
          admissionFeeNonHostel ?? this.admissionFeeNonHostel,
      admissionRenewalFee: admissionRenewalFee ?? this.admissionRenewalFee,
      examFee: examFee ?? this.examFee,
      onlineFee: onlineFee ?? this.onlineFee,
      onlineAdmissionFee: onlineAdmissionFee ?? this.onlineAdmissionFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<FeeStructureModel> get mockFees => const [
        FeeStructureModel(
          id: 'mock-fee-1',
          classId: 'mock-class-1',
          className: 'Darja Awwal (1st Year)',
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami (Alimiyat & Fazilat)',
          simpleId: 1,
          tuitionFee: 5000,
          hostelFee: 3000,
          admissionFeeHostel: 2000,
          admissionFeeNonHostel: 1500,
          admissionRenewalFee: 1000,
          examFee: 500,
          onlineFee: 1200,
          onlineAdmissionFee: 500,
        ),
        FeeStructureModel(
          id: 'mock-fee-3',
          classId: 'mock-class-3',
          className: 'Hifz Class A (Juz 1-10)',
          courseId: 'course-hifz-uuid',
          courseName: 'Hifz-ul-Quran (Tahfeez)',
          simpleId: 2,
          tuitionFee: 4500,
          hostelFee: 2800,
          admissionFeeHostel: 1800,
          admissionFeeNonHostel: 1200,
          admissionRenewalFee: 800,
          examFee: 400,
          onlineFee: 1000,
          onlineAdmissionFee: 400,
        ),
      ];
}
