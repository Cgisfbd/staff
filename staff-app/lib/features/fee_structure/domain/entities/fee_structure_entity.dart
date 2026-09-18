import 'package:equatable/equatable.dart';

/// Clean domain entity representing class-level fee configuration.
class FeeStructureEntity extends Equatable {
  const FeeStructureEntity({
    required this.id,
    required this.classId,
    required this.className,
    this.courseId,
    this.courseName,
    this.simpleId = 1,
    this.tuitionFee = 0,
    this.hostelFee = 0,
    this.admissionFeeHostel = 0,
    this.admissionFeeNonHostel = 0,
    this.admissionRenewalFee = 0,
    this.examFee = 0,
    this.onlineFee = 0,
    this.onlineAdmissionFee = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String classId;
  final String className;
  final String? courseId;
  final String? courseName;
  final int simpleId;

  // Monthly Fees
  final int tuitionFee;
  final int hostelFee;

  // One-time / Admission Fees
  final int admissionFeeHostel;
  final int admissionFeeNonHostel;
  final int admissionRenewalFee;

  // Institutional Fees
  final int examFee;
  final int onlineFee;
  final int onlineAdmissionFee;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Computed Projections
  int get monthlyResidentTotal => tuitionFee + hostelFee;
  int get monthlyDayScholarTotal => tuitionFee;
  int get monthlyOnlineTotal => onlineFee;

  int get annualResidentPackage =>
      admissionFeeHostel + (tuitionFee * 10) + (hostelFee * 10) + examFee;

  int get annualDayScholarPackage =>
      admissionFeeNonHostel + (tuitionFee * 10) + examFee;

  int get annualOnlinePackage =>
      onlineAdmissionFee + (onlineFee * 10) + examFee;

  int get maxTotalFee =>
      tuitionFee +
      (admissionFeeHostel > admissionFeeNonHostel
          ? admissionFeeHostel
          : admissionFeeNonHostel) +
      examFee +
      onlineFee +
      onlineAdmissionFee +
      admissionRenewalFee +
      hostelFee;

  @override
  List<Object?> get props => [
        id,
        classId,
        className,
        courseId,
        courseName,
        simpleId,
        tuitionFee,
        hostelFee,
        admissionFeeHostel,
        admissionFeeNonHostel,
        admissionRenewalFee,
        examFee,
        onlineFee,
        onlineAdmissionFee,
        createdAt,
        updatedAt,
      ];
}
