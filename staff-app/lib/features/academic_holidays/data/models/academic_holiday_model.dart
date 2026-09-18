import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

class AcademicHolidayModel extends AcademicHoliday {
  const AcademicHolidayModel({
    required super.id,
    required super.academicYearId,
    required super.type,
    required super.appliesTo,
    required super.startDate,
    required super.endDate,
    required super.title,
    required super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory AcademicHolidayModel.fromJson(Map<String, dynamic> json) {
    final Map<String, String> parsedTitle = {};
    if (json['title'] is Map) {
      final m = json['title'] as Map;
      m.forEach((key, value) {
        if (value != null) {
          parsedTitle[key.toString()] = value.toString();
        }
      });
    }

    final Map<String, String> parsedDesc = {};
    if (json['description'] is Map) {
      final m = json['description'] as Map;
      m.forEach((key, value) {
        if (value != null) {
          parsedDesc[key.toString()] = value.toString();
        }
      });
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    DateTime? updated;
    if (json['updatedAt'] != null) {
      updated = DateTime.tryParse(json['updatedAt'].toString());
    }

    return AcademicHolidayModel(
      id: json['id']?.toString() ?? '',
      academicYearId: json['academicYearId']?.toString() ?? '',
      type: HolidayType.fromString(json['type']?.toString()),
      appliesTo: HolidayAppliesTo.fromString(json['appliesTo']?.toString()),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      title: parsedTitle,
      description: parsedDesc,
      createdAt: created,
      updatedAt: updated,
    );
  }

  factory AcademicHolidayModel.fromEntity(AcademicHoliday entity) {
    return AcademicHolidayModel(
      id: entity.id,
      academicYearId: entity.academicYearId,
      type: entity.type,
      appliesTo: entity.appliesTo,
      startDate: entity.startDate,
      endDate: entity.endDate,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'appliesTo': appliesTo.value,
      'startDate': startDate,
      'endDate': endDate,
      'title': title,
      'description': description,
    };
  }
}
