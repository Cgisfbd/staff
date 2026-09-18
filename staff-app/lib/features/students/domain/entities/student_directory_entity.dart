/// Pure Dart domain entity representing a student in the directory.
/// Zero Flutter UI or HTTP dependencies (staffRULES.md Rule 1.1).
class StudentDirectoryEntity {
  const StudentDirectoryEntity({
    required this.id,
    required this.rollNo,
    required this.status,
    required this.fullNameEn,
    required this.nameUrdu,
    required this.fatherNameEn,
    this.fatherNameUr = '',
    this.fatherOccupation = '',
    this.motherNameEn = '',
    this.motherNameUr = '',
    this.motherOccupation = '',
    this.dob = '',
    this.gender = 'Male',
    this.caste = '',
    this.aadharNo = '',
    required this.rfidNo,
    this.photoUrl,
    required this.mobile,
    this.altMobile = '',
    required this.fullAddress,
    this.courseId,
    this.courseName = '',
    this.classId,
    required this.className,
    this.modeOfStudy = 'Offline',
    this.hostelFacility = 'Yes',
    this.prevSchoolName = '',
    this.prevSchoolAddress = '',
    this.admissionDate = '',
    this.submittedDocs = const [],
  });

  final String id;
  final int rollNo;
  final String status;
  final String fullNameEn;
  final String nameUrdu;
  final String fatherNameEn;
  final String fatherNameUr;
  final String fatherOccupation;
  final String motherNameEn;
  final String motherNameUr;
  final String motherOccupation;
  final String dob;
  final String gender;
  final String caste;
  final String aadharNo;
  final String rfidNo;
  final String? photoUrl;
  final String mobile;
  final String altMobile;
  final String fullAddress;
  final String? courseId;
  final String courseName;
  final String? classId;
  final String className;
  final String modeOfStudy;
  final String hostelFacility;
  final String prevSchoolName;
  final String prevSchoolAddress;
  final String admissionDate;
  final List<String> submittedDocs;

  bool get isActive => status.toLowerCase() == 'active';
  bool get isDropout => status.toLowerCase() == 'dropout';
  bool get isGraduated => status.toLowerCase() == 'graduated';
}

/// Pure Dart domain entity representing KPI statistics for students.
class StudentStatsEntity {
  const StudentStatsEntity({
    required this.totalActive,
    required this.activeCount,
    required this.dropoutCount,
    required this.graduatedCount,
    required this.offlineCount,
    required this.onlineCount,
    required this.rfidLinked,
  });

  final int totalActive;
  final int activeCount;
  final int dropoutCount;
  final int graduatedCount;
  final int offlineCount;
  final int onlineCount;
  final int rfidLinked;

  static const StudentStatsEntity empty = StudentStatsEntity(
    totalActive: 0,
    activeCount: 0,
    dropoutCount: 0,
    graduatedCount: 0,
    offlineCount: 0,
    onlineCount: 0,
    rfidLinked: 0,
  );
}
