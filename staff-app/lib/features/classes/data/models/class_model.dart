import 'package:staff_app/features/classes/domain/entities/class_entity.dart';

class ClassModel extends ClassEntity {
  const ClassModel({
    required super.id,
    required super.simpleId,
    required super.courseId,
    required super.courseName,
    required super.nameEnglish,
    super.nameUrdu,
    super.capacity = 50,
    super.studentCount = 0,
    super.subjectCount = 0,
    super.bookCount = 0,
    super.hasFeeStructure = false,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id']?.toString() ?? '',
      simpleId: (json['simpleId'] as num?)?.toInt() ?? 1,
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? 'General Department',
      nameEnglish: json['nameEnglish']?.toString() ?? 'Class',
      nameUrdu: json['nameUrdu']?.toString(),
      capacity: (json['capacity'] as num?)?.toInt() ?? 50,
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      subjectCount: (json['subjectCount'] as num?)?.toInt() ?? 0,
      bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
      hasFeeStructure: json['hasFeeStructure'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simpleId': simpleId,
      'courseId': courseId,
      'courseName': courseName,
      'nameEnglish': nameEnglish,
      'nameUrdu': nameUrdu,
      'capacity': capacity,
      'studentCount': studentCount,
      'subjectCount': subjectCount,
      'bookCount': bookCount,
      'hasFeeStructure': hasFeeStructure,
    };
  }

  static List<ClassModel> get mockClasses => const [
        ClassModel(
          id: 'mock-class-1',
          simpleId: 1,
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami (Alimiyat & Fazilat)',
          nameEnglish: 'Darja Awwal (1st Year)',
          nameUrdu: 'درجہ اول',
          capacity: 45,
          studentCount: 38,
          subjectCount: 6,
          bookCount: 8,
          hasFeeStructure: true,
        ),
        ClassModel(
          id: 'mock-class-2',
          simpleId: 2,
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami (Alimiyat & Fazilat)',
          nameEnglish: 'Darja Doim (2nd Year)',
          nameUrdu: 'درجہ دوم',
          capacity: 40,
          studentCount: 35,
          subjectCount: 7,
          bookCount: 10,
          hasFeeStructure: true,
        ),
        ClassModel(
          id: 'mock-class-3',
          simpleId: 3,
          courseId: 'course-hifz-uuid',
          courseName: 'Hifz-ul-Quran (Tahfeez)',
          nameEnglish: 'Hifz Class A (Juz 1-10)',
          nameUrdu: 'حفظ القرآن الف',
          capacity: 30,
          studentCount: 28,
          subjectCount: 3,
          bookCount: 4,
          hasFeeStructure: true,
        ),
        ClassModel(
          id: 'mock-class-4',
          simpleId: 4,
          courseId: 'course-tajweed-uuid',
          courseName: 'Tajweed-wa-Qira\'at',
          nameEnglish: 'Qirat Sab\'ah Specialization',
          nameUrdu: 'قرأت سبعہ تخصص',
          capacity: 25,
          studentCount: 20,
          subjectCount: 4,
          bookCount: 5,
          hasFeeStructure: false,
        ),
      ];
}
