/// Immutable Domain Model representing a student admission registration form.
/// Strictly mirrors the 24 fields from the Enterprise Web ERP Admission Form.
class StudentAdmissionModel {
  const StudentAdmissionModel({
    this.photoPath,
    this.fullNameEn = '',
    this.fullNameUr = '',
    this.fatherNameEn = '',
    this.fatherNameUr = '',
    this.fatherOccupation = '',
    this.motherNameEn = '',
    this.motherNameUr = '',
    this.motherOccupation = '',
    this.dob,
    this.gender = 'Male',
    this.caste = '',
    this.aadharNo = '',
    this.rfidNo = '',
    this.mobile = '',
    this.altMobile = '',
    this.pincode = '',
    this.fullAddress = '',
    this.courseId,
    this.courseName = '',
    this.classId,
    this.className = '',
    required this.admissionDate,
    this.modeOfStudy = 'Offline',
    this.hostelFacility = 'Yes',
    this.prevSchoolName = '',
    this.prevSchoolAddress = '',
  });

  final String? photoPath;
  final String fullNameEn;
  final String fullNameUr;
  final String fatherNameEn;
  final String fatherNameUr;
  final String fatherOccupation;
  final String motherNameEn;
  final String motherNameUr;
  final String motherOccupation;
  final DateTime? dob;
  final String gender;
  final String caste;
  final String aadharNo;
  final String rfidNo;
  final String mobile;
  final String altMobile;
  final String pincode;
  final String fullAddress;
  final String? courseId;
  final String courseName;
  final String? classId;
  final String className;
  final DateTime admissionDate;
  final String modeOfStudy;
  final String hostelFacility;
  final String prevSchoolName;
  final String prevSchoolAddress;

  StudentAdmissionModel copyWith({
    String? photoPath,
    String? fullNameEn,
    String? fullNameUr,
    String? fatherNameEn,
    String? fatherNameUr,
    String? fatherOccupation,
    String? motherNameEn,
    String? motherNameUr,
    String? motherOccupation,
    DateTime? dob,
    String? gender,
    String? caste,
    String? aadharNo,
    String? rfidNo,
    String? mobile,
    String? altMobile,
    String? pincode,
    String? fullAddress,
    String? courseId,
    String? courseName,
    String? classId,
    String? className,
    DateTime? admissionDate,
    String? modeOfStudy,
    String? hostelFacility,
    String? prevSchoolName,
    String? prevSchoolAddress,
  }) {
    return StudentAdmissionModel(
      photoPath: photoPath ?? this.photoPath,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      fullNameUr: fullNameUr ?? this.fullNameUr,
      fatherNameEn: fatherNameEn ?? this.fatherNameEn,
      fatherNameUr: fatherNameUr ?? this.fatherNameUr,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherNameEn: motherNameEn ?? this.motherNameEn,
      motherNameUr: motherNameUr ?? this.motherNameUr,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      caste: caste ?? this.caste,
      aadharNo: aadharNo ?? this.aadharNo,
      rfidNo: rfidNo ?? this.rfidNo,
      mobile: mobile ?? this.mobile,
      altMobile: altMobile ?? this.altMobile,
      pincode: pincode ?? this.pincode,
      fullAddress: fullAddress ?? this.fullAddress,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      admissionDate: admissionDate ?? this.admissionDate,
      modeOfStudy: modeOfStudy ?? this.modeOfStudy,
      hostelFacility: hostelFacility ?? this.hostelFacility,
      prevSchoolName: prevSchoolName ?? this.prevSchoolName,
      prevSchoolAddress: prevSchoolAddress ?? this.prevSchoolAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_url': photoPath,
      'full_name_en': fullNameEn,
      'full_name_ur': fullNameUr,
      'father_name_en': fatherNameEn,
      'father_name_ur': fatherNameUr,
      'father_occupation': fatherOccupation,
      'mother_name_en': motherNameEn,
      'mother_name_ur': motherNameUr,
      'mother_occupation': motherOccupation,
      'dob': dob?.toIso8601String().split('T').first,
      'gender': gender,
      'caste': caste,
      'aadhar_no': aadharNo,
      'rfid_no': rfidNo,
      'mobile': mobile,
      'alt_mobile': altMobile,
      'full_address': fullAddress,
      'course_id': courseId,
      'course_name': courseName,
      'class_id': classId,
      'class_name': className,
      'admission_date': admissionDate.toIso8601String().split('T').first,
      'mode_of_study': modeOfStudy,
      'hostel_facility': hostelFacility,
      'prev_school_name': prevSchoolName,
      'prev_school_address': prevSchoolAddress,
    };
  }
}
