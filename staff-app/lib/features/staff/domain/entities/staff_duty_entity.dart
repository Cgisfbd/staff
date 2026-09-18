import 'package:equatable/equatable.dart';

/// Single Assigned Teaching Book Item (Course ➔ Class ➔ Book)
class TeachingBookItem extends Equatable {
  const TeachingBookItem({
    required this.courseName,
    required this.className,
    required this.bookName,
  });

  final String courseName;
  final String className;
  final String bookName;

  @override
  List<Object?> get props => [courseName, className, bookName];
}

/// Domain Entity for Staff Academic Duty Allocation (Classes + Books)
class StaffDutyEntity extends Equatable {
  const StaffDutyEntity({
    required this.facultyId,
    required this.staffCode,
    required this.fullNameEn,
    this.fullNameUr = '',
    this.designation = '',
    this.department = '',
    this.phone = '',
    this.avatar = '',
    this.isDutyConfigured = false,
    required this.assignedClasses,
    required this.assignedBooks,
    this.academicYear = '2026-2027',
  });

  final String facultyId;
  final int staffCode;
  final String fullNameEn;
  final String fullNameUr;
  final String designation;
  final String department;
  final String phone;
  final String avatar;
  final bool isDutyConfigured;
  final List<String> assignedClasses;
  final List<TeachingBookItem> assignedBooks;
  final String academicYear;

  StaffDutyEntity copyWith({
    String? facultyId,
    int? staffCode,
    String? fullNameEn,
    String? fullNameUr,
    String? designation,
    String? department,
    String? phone,
    String? avatar,
    bool? isDutyConfigured,
    List<String>? assignedClasses,
    List<TeachingBookItem>? assignedBooks,
    String? academicYear,
  }) {
    return StaffDutyEntity(
      facultyId: facultyId ?? this.facultyId,
      staffCode: staffCode ?? this.staffCode,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      fullNameUr: fullNameUr ?? this.fullNameUr,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isDutyConfigured: isDutyConfigured ?? this.isDutyConfigured,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      assignedBooks: assignedBooks ?? this.assignedBooks,
      academicYear: academicYear ?? this.academicYear,
    );
  }

  @override
  List<Object?> get props => [
        facultyId,
        staffCode,
        fullNameEn,
        fullNameUr,
        designation,
        department,
        phone,
        avatar,
        isDutyConfigured,
        assignedClasses,
        assignedBooks,
        academicYear,
      ];
}

/// Domain Entity for Duty Dashboard Analytics KPI Deck
class StaffDutyStatsEntity extends Equatable {
  const StaffDutyStatsEntity({
    required this.totalStaff,
    required this.totalClassesCovered,
    required this.totalBooksAllocated,
    required this.unassignedStaffCount,
  });

  final int totalStaff;
  final int totalClassesCovered;
  final int totalBooksAllocated;
  final int unassignedStaffCount;

  @override
  List<Object?> get props => [
        totalStaff,
        totalClassesCovered,
        totalBooksAllocated,
        unassignedStaffCount,
      ];
}
