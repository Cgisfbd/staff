import 'package:equatable/equatable.dart';

/// Clean Domain Entity representing a Teacher / Faculty Member in the TaleemOne ERP Ecosystem.
class TeacherDirectoryEntity extends Equatable {
  const TeacherDirectoryEntity({
    required this.id,
    required this.staffCode,
    required this.fullNameEn,
    required this.nameUrdu,
    required this.fatherNameEn,
    required this.fatherNameUr,
    required this.dob,
    required this.gender,
    required this.phone,
    this.familyPhone = '',
    this.email = '',
    this.aadharNo = '',
    this.rfidNo = '',
    this.fullAddress = '',
    this.photoUrl,
    required this.qualification,
    required this.designation,
    this.department = '',
    this.courseId,
    this.courseName,
    this.experienceYears = 0,
    required this.joiningDate,
    this.dutyMode = 'Hostel Resident',
    this.residenceStatus = 'Hostel Resident',
    this.monthlySalary = 0,
    this.bankName = '',
    this.bankAccountNo = '',
    this.bankIfsc = '',
    this.pincode = '',
    this.submittedDocs = const [],
    this.status = 'Active',
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final int staffCode;
  final String fullNameEn;
  final String nameUrdu;
  final String fatherNameEn;
  final String fatherNameUr;
  final String dob;
  final String gender;
  final String phone;
  final String familyPhone;
  final String email;
  final String aadharNo;
  final String rfidNo;
  final String fullAddress;
  final String? photoUrl;
  final String qualification;
  final String designation;
  final String department;
  final String? courseId;
  final String? courseName;
  final int experienceYears;
  final String joiningDate;
  final String dutyMode;
  final String residenceStatus;
  final double monthlySalary;
  final String bankName;
  final String bankAccountNo;
  final String bankIfsc;
  final String pincode;
  final List<String> submittedDocs;
  final String status;
  final bool isActive;
  final String? createdAt;

  @override
  List<Object?> get props => [
        id,
        staffCode,
        fullNameEn,
        nameUrdu,
        fatherNameEn,
        fatherNameUr,
        dob,
        gender,
        phone,
        familyPhone,
        email,
        aadharNo,
        rfidNo,
        fullAddress,
        photoUrl,
        qualification,
        designation,
        department,
        courseId,
        courseName,
        experienceYears,
        joiningDate,
        dutyMode,
        residenceStatus,
        monthlySalary,
        bankName,
        bankAccountNo,
        bankIfsc,
        pincode,
        submittedDocs,
        status,
        isActive,
        createdAt,
      ];
}

/// Clean Domain Entity representing KPI summary stats for Faculty & Staff.
class TeacherStatsEntity extends Equatable {
  const TeacherStatsEntity({
    required this.totalFaculty,
    required this.activeCount,
    required this.hostelResidentCount,
    required this.dayDutyCount,
    required this.onlineCount,
  });

  final int totalFaculty;
  final int activeCount;
  final int hostelResidentCount;
  final int dayDutyCount;
  final int onlineCount;

  @override
  List<Object?> get props => [
        totalFaculty,
        activeCount,
        hostelResidentCount,
        dayDutyCount,
        onlineCount,
      ];
}
