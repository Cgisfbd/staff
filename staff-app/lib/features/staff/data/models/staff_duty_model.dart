import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';

/// Data Model for Teaching Book Assignment
class TeachingBookModel extends TeachingBookItem {
  const TeachingBookModel({
    required super.courseName,
    required super.className,
    required super.bookName,
  });

  factory TeachingBookModel.fromJson(Map<String, dynamic> json) {
    return TeachingBookModel(
      courseName: json['courseName']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      bookName: json['kitabName']?.toString() ?? json['bookName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseName': courseName,
      'className': className,
      'kitabName': bookName,
      'bookName': bookName,
    };
  }
}

/// Data Model for Staff Academic Duty Allocation
class StaffDutyModel extends StaffDutyEntity {
  const StaffDutyModel({
    required super.facultyId,
    required super.staffCode,
    required super.fullNameEn,
    super.fullNameUr = '',
    super.designation = '',
    super.department = '',
    super.phone = '',
    super.avatar = '',
    super.isDutyConfigured = false,
    required super.assignedClasses,
    required super.assignedBooks,
    super.academicYear = '2026-2027',
  });

  factory StaffDutyModel.fromJson(Map<String, dynamic> json) {
    final rawBooks = (json['teachingAssignments'] as List<dynamic>?) ??
        (json['assignedBooks'] as List<dynamic>?) ??
        [];
    final books = rawBooks
        .map((b) => TeachingBookModel.fromJson(Map<String, dynamic>.from(b as Map)))
        .toList();

    final rawClasses = (json['attendanceClasses'] as List<dynamic>?) ??
        (json['assignedClasses'] as List<dynamic>?) ??
        [];
    final classes = rawClasses.map((c) => c.toString()).toList();

    return StaffDutyModel(
      facultyId: json['facultyId']?.toString() ?? json['id']?.toString() ?? '',
      staffCode: json['staffCode'] is int
          ? json['staffCode'] as int
          : int.tryParse(json['staffCode']?.toString() ?? '101') ?? 101,
      fullNameEn: json['fullNameEn']?.toString() ?? json['name']?.toString() ?? 'Faculty Member',
      fullNameUr: json['fullNameUr']?.toString() ?? json['nameUrdu']?.toString() ?? '',
      designation: json['designation']?.toString() ?? 'Mudarris',
      department: json['department']?.toString() ?? 'General Islamic',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? json['photoUrl']?.toString() ?? '',
      isDutyConfigured: json['isDutyConfigured'] == true || classes.isNotEmpty || books.isNotEmpty,
      assignedClasses: classes,
      assignedBooks: books,
      academicYear: json['academicYear']?.toString() ?? '2026-2027',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facultyId': facultyId,
      'staffCode': staffCode,
      'fullNameEn': fullNameEn,
      'fullNameUr': fullNameUr,
      'designation': designation,
      'department': department,
      'phone': phone,
      'avatar': avatar,
      'isDutyConfigured': isDutyConfigured,
      'attendanceClasses': assignedClasses,
      'assignedClasses': assignedClasses,
      'teachingAssignments': assignedBooks
          .map((b) => (b is TeachingBookModel ? b : TeachingBookModel(
                courseName: b.courseName,
                className: b.className,
                bookName: b.bookName,
              )).toJson())
          .toList(),
      'academicYear': academicYear,
    };
  }

  /// High-Fidelity Realistic Madarsa Seed Dataset for Offline & Testing
  static final List<StaffDutyModel> seedData = [
    const StaffDutyModel(
      facultyId: 'fac-101-mufti-abdul-rahman',
      staffCode: 101,
      fullNameEn: 'Mufti Abdul Rahman Qasmi',
      fullNameUr: 'مفتی عبد الرحمن قاسمی',
      designation: 'Senior Ustad / Head of Fiqh',
      department: 'Shu’ba-e-Ifta & Fiqh',
      phone: '+91 98765 43210',
      isDutyConfigured: true,
      assignedClasses: [
        'Aalimiyat 1st Year',
        'Aalimiyat 2nd Year',
        'Fazilat Specialization',
      ],
      assignedBooks: [
        TeachingBookModel(
          courseName: 'Aalimiyat Degree Course',
          className: 'Aalimiyat 1st Year',
          bookName: 'Mukhtasar Al-Qudoori (Part 1)',
        ),
        TeachingBookModel(
          courseName: 'Aalimiyat Degree Course',
          className: 'Aalimiyat 1st Year',
          bookName: 'Noor-ul-Izah (Kitab-ut-Taharah)',
        ),
        TeachingBookModel(
          courseName: 'Aalimiyat Degree Course',
          className: 'Aalimiyat 2nd Year',
          bookName: 'Hidayah (Awwalain - Fiqh)',
        ),
      ],
    ),
    const StaffDutyModel(
      facultyId: 'fac-102-qari-mohammad-salman',
      staffCode: 102,
      fullNameEn: 'Qari Mohammad Salman',
      fullNameUr: 'قاری محمد سلمان',
      designation: 'Head Qari / Nazim-e-Hifz',
      department: 'Shu’ba-e-Hifz & Tajweed',
      phone: '+91 98765 43211',
      isDutyConfigured: true,
      assignedClasses: [
        'Hifz-ul-Quran & Tajweed',
      ],
      assignedBooks: [
        TeachingBookModel(
          courseName: 'Hifz-ul-Quran & Tajweed',
          className: 'Hifz-ul-Quran & Tajweed',
          bookName: 'Hifz-e-Quran Part 1 (Daur-e-Sabaq)',
        ),
        TeachingBookModel(
          courseName: 'Hifz-ul-Quran & Tajweed',
          className: 'Hifz-ul-Quran & Tajweed',
          bookName: 'Al-Jazariyyah (Tajweed Rules)',
        ),
      ],
    ),
    const StaffDutyModel(
      facultyId: 'fac-103-maulana-zubair-ahmad',
      staffCode: 103,
      fullNameEn: 'Maulana Zubair Ahmad',
      fullNameUr: 'مولانا زبیر احمد',
      designation: 'Senior Ustad (Arabic Literature)',
      department: 'Shu’ba-e-Arabi Adab',
      phone: '+91 98765 43212',
      isDutyConfigured: true,
      assignedClasses: [
        'Aalimiyat 1st Year',
        'Aalimiyat 2nd Year',
      ],
      assignedBooks: [
        TeachingBookModel(
          courseName: 'Aalimiyat Degree Course',
          className: 'Aalimiyat 1st Year',
          bookName: 'Hidayat-un-Nahw (Grammar)',
        ),
        TeachingBookModel(
          courseName: 'Aalimiyat Degree Course',
          className: 'Aalimiyat 2nd Year',
          bookName: 'Nafhat-ul-Arab (Literature)',
        ),
      ],
    ),
    const StaffDutyModel(
      facultyId: 'fac-104-dr-tariq-mahmood',
      staffCode: 104,
      fullNameEn: 'Dr. Tariq Mahmood',
      fullNameUr: 'ڈاکٹر طارق محمود',
      designation: 'Lecturer in Mathematics & Science',
      department: 'Secondary Modern Curriculum',
      phone: '+91 98765 43213',
      isDutyConfigured: true,
      assignedClasses: [
        'Secondary Class 10th',
        'Secondary Class 9th',
      ],
      assignedBooks: [
        TeachingBookModel(
          courseName: 'Secondary Modern Curriculum',
          className: 'Secondary Class 10th',
          bookName: 'NCERT Mathematics (Standard 10)',
        ),
        TeachingBookModel(
          courseName: 'Secondary Modern Curriculum',
          className: 'Secondary Class 9th',
          bookName: 'General Science & Environment',
        ),
      ],
    ),
    const StaffDutyModel(
      facultyId: 'fac-105-hafiz-abu-bakr',
      staffCode: 105,
      fullNameEn: 'Hafiz Abu Bakr',
      fullNameUr: 'حافظ ابو بکر',
      designation: 'Assistant Teacher / Nazim-e-Darul Iqama',
      department: 'Primary Religious Studies',
      phone: '+91 98765 43214',
      isDutyConfigured: false,
      assignedClasses: [],
      assignedBooks: [],
    ),
  ];
}

/// Data Model for Duty Analytics Stats
class StaffDutyStatsModel extends StaffDutyStatsEntity {
  const StaffDutyStatsModel({
    required super.totalStaff,
    required super.totalClassesCovered,
    required super.totalBooksAllocated,
    required super.unassignedStaffCount,
  });

  factory StaffDutyStatsModel.fromDuties(List<StaffDutyEntity> duties) {
    final uniqueClasses = <String>{};
    int totalBooks = 0;
    int unassigned = 0;

    for (final d in duties) {
      uniqueClasses.addAll(d.assignedClasses);
      totalBooks += d.assignedBooks.length;
      if (!d.isDutyConfigured || (d.assignedClasses.isEmpty && d.assignedBooks.isEmpty)) {
        unassigned++;
      }
    }

    return StaffDutyStatsModel(
      totalStaff: duties.length,
      totalClassesCovered: uniqueClasses.length,
      totalBooksAllocated: totalBooks,
      unassignedStaffCount: unassigned,
    );
  }
}
