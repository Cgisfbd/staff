import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';

class TeacherDirectoryModel extends TeacherDirectoryEntity {
  const TeacherDirectoryModel({
    required super.id,
    required super.staffCode,
    required super.fullNameEn,
    required super.nameUrdu,
    required super.fatherNameEn,
    required super.fatherNameUr,
    required super.dob,
    required super.gender,
    required super.phone,
    super.familyPhone = '',
    super.email = '',
    super.aadharNo = '',
    super.rfidNo = '',
    super.fullAddress = '',
    super.photoUrl,
    required super.qualification,
    required super.designation,
    super.department = '',
    super.courseId,
    super.courseName,
    super.experienceYears = 0,
    required super.joiningDate,
    super.dutyMode = 'Hostel Resident',
    super.residenceStatus = 'Hostel Resident',
    super.monthlySalary = 0,
    super.bankName = '',
    super.bankAccountNo = '',
    super.bankIfsc = '',
    super.pincode = '',
    super.submittedDocs = const [],
    super.status = 'Active',
    super.isActive = true,
    super.createdAt,
  });

  factory TeacherDirectoryModel.fromJson(Map<String, dynamic> json) {
    final rawSalary = json['monthlySalary'] ?? json['salary'] ?? 0;
    double salary = 0;
    if (rawSalary is num) {
      salary = rawSalary.toDouble();
    } else if (rawSalary is String) {
      salary = double.tryParse(rawSalary) ?? 0;
    }

    final rawExp = json['experienceYears'] ?? json['experience'] ?? 0;
    int exp = 0;
    if (rawExp is num) {
      exp = rawExp.toInt();
    } else if (rawExp is String) {
      exp = int.tryParse(rawExp) ?? 0;
    }

    final rawCode = json['staffCode'] ?? json['code'] ?? 101;
    int code = 101;
    if (rawCode is num) {
      code = rawCode.toInt();
    } else if (rawCode is String) {
      code = int.tryParse(rawCode) ?? 101;
    }

    final active = json['isActive'] ?? json['is_active'] ?? true;
    final statusStr = json['status']?.toString() ?? (active == false ? 'Terminated' : 'Active');

    final rawDocs = json['submittedDocs'] ?? json['submitted_docs'] ?? json['documents'];
    List<String> docsList = [];
    if (rawDocs is List) {
      docsList = rawDocs.map((e) => e.toString()).toList();
    } else if (rawDocs is String && rawDocs.isNotEmpty) {
      docsList = rawDocs.split(',').map((e) => e.trim()).toList();
    }

    return TeacherDirectoryModel(
      id: json['id']?.toString() ?? '',
      staffCode: code,
      fullNameEn: json['fullNameEn']?.toString() ?? json['name']?.toString() ?? '',
      nameUrdu: json['fullNameUr']?.toString() ?? json['nameUrdu']?.toString() ?? '',
      fatherNameEn: json['fatherNameEn']?.toString() ?? json['fatherName']?.toString() ?? '',
      fatherNameUr: json['fatherNameUr']?.toString() ?? json['fatherNameUrdu']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Male',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      familyPhone: json['familyPhone']?.toString() ?? json['altPhone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      aadharNo: json['aadharNo']?.toString() ?? json['aadharNumber']?.toString() ?? '',
      rfidNo: json['rfidNo']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? json['address']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
      qualification: json['qualification']?.toString() ?? 'Fazilat',
      designation: json['designation']?.toString() ?? 'Mudarris',
      department: json['department']?.toString() ?? json['courseName']?.toString() ?? '',
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString(),
      experienceYears: exp,
      joiningDate: json['joiningDate']?.toString() ?? '',
      dutyMode: json['dutyMode']?.toString() ?? json['residenceStatus']?.toString() ?? 'Hostel Resident',
      residenceStatus: json['residenceStatus']?.toString() ?? json['dutyMode']?.toString() ?? 'Hostel Resident',
      monthlySalary: salary,
      bankName: json['bankName']?.toString() ?? '',
      bankAccountNo: json['bankAccountNo']?.toString() ?? json['accountNumber']?.toString() ?? '',
      bankIfsc: json['bankIfsc']?.toString() ?? json['ifscCode']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      submittedDocs: docsList,
      status: statusStr,
      isActive: active is bool ? active : true,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  factory TeacherDirectoryModel.fromEntity(TeacherDirectoryEntity entity) {
    return TeacherDirectoryModel(
      id: entity.id,
      staffCode: entity.staffCode,
      fullNameEn: entity.fullNameEn,
      nameUrdu: entity.nameUrdu,
      fatherNameEn: entity.fatherNameEn,
      fatherNameUr: entity.fatherNameUr,
      dob: entity.dob,
      gender: entity.gender,
      phone: entity.phone,
      familyPhone: entity.familyPhone,
      email: entity.email,
      aadharNo: entity.aadharNo,
      rfidNo: entity.rfidNo,
      fullAddress: entity.fullAddress,
      photoUrl: entity.photoUrl,
      qualification: entity.qualification,
      designation: entity.designation,
      department: entity.department,
      courseId: entity.courseId,
      courseName: entity.courseName,
      experienceYears: entity.experienceYears,
      joiningDate: entity.joiningDate,
      dutyMode: entity.dutyMode,
      residenceStatus: entity.residenceStatus,
      monthlySalary: entity.monthlySalary,
      bankName: entity.bankName,
      bankAccountNo: entity.bankAccountNo,
      bankIfsc: entity.bankIfsc,
      pincode: entity.pincode,
      submittedDocs: entity.submittedDocs,
      status: entity.status,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffCode': staffCode,
      'fullNameEn': fullNameEn,
      'fullNameUr': nameUrdu,
      'fatherNameEn': fatherNameEn,
      'fatherNameUr': fatherNameUr,
      'dob': dob,
      'gender': gender,
      'phone': phone,
      'familyPhone': familyPhone,
      'email': email,
      'aadharNo': aadharNo,
      'rfidNo': rfidNo,
      'fullAddress': fullAddress,
      'photoUrl': photoUrl,
      'qualification': qualification,
      'designation': designation,
      'department': department,
      'courseId': courseId,
      'courseName': courseName,
      'experienceYears': experienceYears.toString(),
      'joiningDate': joiningDate,
      'dutyMode': dutyMode,
      'residenceStatus': residenceStatus,
      'monthlySalary': monthlySalary.toString(),
      'bankName': bankName,
      'bankAccountNo': bankAccountNo,
      'bankIfsc': bankIfsc,
      'pincode': pincode,
      'submittedDocs': submittedDocs,
      'status': status,
      'isActive': isActive,
    };
  }

  static const List<TeacherDirectoryModel> mockSeedList = [
    TeacherDirectoryModel(
      id: 'staff-001',
      staffCode: 101,
      fullNameEn: 'Mufti Abdul Rahman Qasmi',
      nameUrdu: 'مفتی عبد الرحمن قاسمی',
      fatherNameEn: 'Maulana Hafizullah',
      fatherNameUr: 'مولانا حفیظ اللہ',
      dob: '15 Jul 1978',
      gender: 'Male',
      phone: '9876543210',
      familyPhone: '9876543211',
      email: 'mufti.abdulrahman@taleemone.in',
      aadharNo: '789012345678',
      rfidNo: 'RF-STF-001',
      fullAddress: 'Madarsa Campus Quarter A-1, Deoband Road, Saharanpur, UP',
      qualification: 'Mufti & Fazilat',
      designation: 'Principal / Muhtamim',
      department: 'Islamic Jurisprudence (Fiqh)',
      experienceYears: 22,
      joiningDate: '01 Jul 2008',
      dutyMode: 'Hostel Resident',
      residenceStatus: 'Hostel Resident',
      monthlySalary: 45000,
      bankName: 'State Bank of India',
      bankAccountNo: '30987654321',
      bankIfsc: 'SBIN0001234',
      status: 'Active',
      isActive: true,
      createdAt: '2024-01-10T10:00:00.000Z',
    ),
    TeacherDirectoryModel(
      id: 'staff-002',
      staffCode: 102,
      fullNameEn: 'Qari Mohammad Salman',
      nameUrdu: 'قاری محمد سلمان',
      fatherNameEn: 'Hafiz Noor Mohammad',
      fatherNameUr: 'حافظ نور محمد',
      dob: '20 Aug 1985',
      gender: 'Male',
      phone: '9876543212',
      familyPhone: '9876543213',
      email: 'qari.salman@taleemone.in',
      aadharNo: '890123456789',
      rfidNo: 'RF-STF-002',
      fullAddress: 'Noor Manzil, Civil Lines, Moradabad, UP',
      qualification: 'Qirat Sab’ah & Hafiz',
      designation: 'Head Qari / Nazim-e-Hifz',
      department: 'Hifz & Tajweed',
      experienceYears: 16,
      joiningDate: '15 Jul 2012',
      dutyMode: 'Hostel Resident',
      residenceStatus: 'Hostel Resident',
      monthlySalary: 38000,
      bankName: 'Punjab National Bank',
      bankAccountNo: '40987654322',
      bankIfsc: 'PUNB0002345',
      status: 'Active',
      isActive: true,
      createdAt: '2024-01-11T10:00:00.000Z',
    ),
    TeacherDirectoryModel(
      id: 'staff-003',
      staffCode: 103,
      fullNameEn: 'Maulana Zubair Ahmad',
      nameUrdu: 'مولانا زبیر احمد',
      fatherNameEn: 'Dr. Bashir Ahmad',
      fatherNameUr: 'ڈاکٹر بشیر احمد',
      dob: '10 May 1990',
      gender: 'Male',
      phone: '9876543214',
      familyPhone: '9876543215',
      email: 'zubair.ahmad@taleemone.in',
      aadharNo: '901234567890',
      rfidNo: 'RF-STF-003',
      fullAddress: 'Madani Nagar, Street 4, Lucknow, UP',
      qualification: 'Fazilat & M.A. Arabic',
      designation: 'Senior Ustad',
      department: 'Hadith & Arabic Literature',
      experienceYears: 11,
      joiningDate: '01 Aug 2016',
      dutyMode: 'Day Scholar',
      residenceStatus: 'Day Scholar',
      monthlySalary: 32000,
      bankName: 'HDFC Bank',
      bankAccountNo: '50987654323',
      bankIfsc: 'HDFC0003456',
      status: 'Active',
      isActive: true,
      createdAt: '2024-01-12T10:00:00.000Z',
    ),
    TeacherDirectoryModel(
      id: 'staff-004',
      staffCode: 104,
      fullNameEn: 'Dr. Tariq Mahmood Siddiqui',
      nameUrdu: 'ڈاکٹر طارق محمود صدیقی',
      fatherNameEn: 'Mushtaq Ahmad Siddiqui',
      fatherNameUr: 'مشتاق احمد صدیقی',
      dob: '05 Jan 1982',
      gender: 'Male',
      phone: '9876543216',
      familyPhone: '9876543217',
      email: 'dr.tariq@taleemone.in',
      aadharNo: '678901234567',
      rfidNo: 'RF-STF-004',
      fullAddress: 'Aligarh Road, Near Jamia Market, Bulandshahr, UP',
      qualification: 'Ph.D. Islamic History',
      designation: 'Vice Principal / Naib Muhtamim',
      department: 'Islamic History & Usul',
      experienceYears: 18,
      joiningDate: '10 Jul 2014',
      dutyMode: 'Hostel Resident',
      residenceStatus: 'Hostel Resident',
      monthlySalary: 42000,
      bankName: 'Bank of Baroda',
      bankAccountNo: '60987654324',
      bankIfsc: 'BARB0004567',
      status: 'Active',
      isActive: true,
      createdAt: '2024-01-13T10:00:00.000Z',
    ),
    TeacherDirectoryModel(
      id: 'staff-005',
      staffCode: 105,
      fullNameEn: 'Hafiz Abu Bakr Madani',
      nameUrdu: 'حافظ ابو بکر مدنی',
      fatherNameEn: 'Ibrahim Madani',
      fatherNameUr: 'ابراہیم مدنی',
      dob: '12 Sep 1993',
      gender: 'Male',
      phone: '9876543218',
      familyPhone: '9876543219',
      email: 'abubakr@taleemone.in',
      aadharNo: '567890123456',
      rfidNo: 'RF-STF-005',
      fullAddress: 'Mohalla Qazi Khel, Bareilly, UP',
      qualification: 'Hafiz & Alimiat',
      designation: 'Mudarris (Primary)',
      department: 'Quran & Basic Urdu/Arabi',
      experienceYears: 7,
      joiningDate: '01 Jul 2019',
      dutyMode: 'Day Scholar',
      residenceStatus: 'Day Scholar',
      monthlySalary: 26000,
      bankName: 'Canara Bank',
      bankAccountNo: '70987654325',
      bankIfsc: 'CNRB0005678',
      status: 'Active',
      isActive: true,
      createdAt: '2024-01-14T10:00:00.000Z',
    ),
  ];
}

class TeacherStatsModel extends TeacherStatsEntity {
  const TeacherStatsModel({
    required super.totalFaculty,
    required super.activeCount,
    required super.hostelResidentCount,
    required super.dayDutyCount,
    required super.onlineCount,
  });

  factory TeacherStatsModel.fromJson(Map<String, dynamic> json) {
    return TeacherStatsModel(
      totalFaculty: (json['totalFaculty'] ?? json['total'] ?? 0) as int,
      activeCount: (json['activeCount'] ?? json['active'] ?? 0) as int,
      hostelResidentCount: (json['hostelResidentCount'] ?? json['hostel'] ?? 0) as int,
      dayDutyCount: (json['dayDutyCount'] ?? json['dayScholar'] ?? 0) as int,
      onlineCount: (json['onlineCount'] ?? json['online'] ?? 0) as int,
    );
  }

  static const TeacherStatsModel mockStats = TeacherStatsModel(
    totalFaculty: 24,
    activeCount: 22,
    hostelResidentCount: 16,
    dayDutyCount: 6,
    onlineCount: 2,
  );
}
