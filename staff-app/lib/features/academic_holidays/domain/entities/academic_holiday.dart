import 'package:equatable/equatable.dart';

enum HolidayType {
  religious('RELIGIOUS', 'Religious', 'مذہبی'),
  national('NATIONAL', 'National', 'قومی'),
  institutional('INSTITUTIONAL', 'Madrasa', 'ادارہ جاتی');

  const HolidayType(this.value, this.label, this.urduLabel);
  final String value;
  final String label;
  final String urduLabel;

  static HolidayType fromString(String? val) {
    return HolidayType.values.firstWhere(
      (e) => e.value.toUpperCase() == val?.toUpperCase(),
      orElse: () => HolidayType.religious,
    );
  }
}

enum HolidayAppliesTo {
  all('ALL', 'All', 'All (Staff & Students)'),
  studentsOnly('STUDENTS_ONLY', 'Students', 'Students Only (Staff Working)'),
  staffOnly('STAFF_ONLY', 'Staff', 'Staff Only');

  const HolidayAppliesTo(this.value, this.label, this.fullLabel);
  final String value;
  final String label;
  final String fullLabel;

  static HolidayAppliesTo fromString(String? val) {
    return HolidayAppliesTo.values.firstWhere(
      (e) => e.value.toUpperCase() == val?.toUpperCase(),
      orElse: () => HolidayAppliesTo.all,
    );
  }
}

class AcademicHoliday extends Equatable {
  const AcademicHoliday({
    required this.id,
    required this.academicYearId,
    required this.type,
    required this.appliesTo,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String academicYearId;
  final HolidayType type;
  final HolidayAppliesTo appliesTo;
  final String startDate; // YYYY-MM-DD
  final String endDate;   // YYYY-MM-DD
  final Map<String, String> title;       // en, ur, hi
  final Map<String, String> description; // en, ur, hi
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get titleEn => title['en'] ?? '';
  String get titleUr => title['ur'] ?? '';
  String get titleHi => title['hi'] ?? '';

  String get descEn => description['en'] ?? '';
  String get descUr => description['ur'] ?? '';
  String get descHi => description['hi'] ?? '';

  int get durationDays {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays + 1;
    } catch (_) {
      return 1;
    }
  }

  bool get isSingleDay => startDate == endDate;

  AcademicHoliday copyWith({
    String? id,
    String? academicYearId,
    HolidayType? type,
    HolidayAppliesTo? appliesTo,
    String? startDate,
    String? endDate,
    Map<String, String>? title,
    Map<String, String>? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademicHoliday(
      id: id ?? this.id,
      academicYearId: academicYearId ?? this.academicYearId,
      type: type ?? this.type,
      appliesTo: appliesTo ?? this.appliesTo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        academicYearId,
        type,
        appliesTo,
        startDate,
        endDate,
        title,
        description,
        createdAt,
        updatedAt,
      ];
}
