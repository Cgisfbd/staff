import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.simpleId,
    required super.classId,
    required super.className,
    super.courseId,
    super.courseName,
    required super.nameEnglish,
    required super.nameUrdu,
    super.bookCount = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id']?.toString() ?? '',
      simpleId: (json['simpleId'] as num?)?.toInt() ?? 1,
      classId: json['classId']?.toString() ?? '',
      className: json['className']?.toString() ?? 'General Class',
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString(),
      nameEnglish: json['nameEnglish']?.toString() ?? '',
      nameUrdu: json['nameUrdu']?.toString() ?? '',
      bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simpleId': simpleId,
      'classId': classId,
      'className': className,
      if (courseId != null) 'courseId': courseId,
      if (courseName != null) 'courseName': courseName,
      'nameEnglish': nameEnglish,
      'nameUrdu': nameUrdu,
      'bookCount': bookCount,
    };
  }

  static List<SubjectModel> get mockSubjects => const [
        SubjectModel(
          id: 'mock-sub-1',
          simpleId: 1,
          classId: 'mock-class-1',
          className: 'Darja Awwal (1st Year)',
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami',
          nameEnglish: 'Fiqh (Islamic Jurisprudence)',
          nameUrdu: 'فقہ اسلامی',
          bookCount: 2,
        ),
        SubjectModel(
          id: 'mock-sub-2',
          simpleId: 2,
          classId: 'mock-class-1',
          className: 'Darja Awwal (1st Year)',
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami',
          nameEnglish: 'Nahw (Arabic Syntax)',
          nameUrdu: 'نحو و اعراب',
          bookCount: 2,
        ),
        SubjectModel(
          id: 'mock-sub-3',
          simpleId: 3,
          classId: 'mock-class-1',
          className: 'Darja Awwal (1st Year)',
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami',
          nameEnglish: 'Sarf (Arabic Morphology)',
          nameUrdu: 'صرف و اشتقاق',
          bookCount: 1,
        ),
        SubjectModel(
          id: 'mock-sub-4',
          simpleId: 4,
          classId: 'mock-class-2',
          className: 'Darja Doim (2nd Year)',
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami',
          nameEnglish: 'Hadith Studies',
          nameUrdu: 'علوم الحدیث',
          bookCount: 3,
        ),
        SubjectModel(
          id: 'mock-sub-5',
          simpleId: 5,
          classId: 'mock-class-2',
          className: 'Darja Doim (2nd Year)',
          courseId: 'course-dars-e-nizami-uuid',
          courseName: 'Dars-e-Nizami',
          nameEnglish: 'Arabic Literature & Composition',
          nameUrdu: 'ادب عربی و انشاء',
          bookCount: 2,
        ),
        SubjectModel(
          id: 'mock-sub-6',
          simpleId: 6,
          classId: 'mock-class-3',
          className: 'Hifz Class A (Juz 1-10)',
          courseId: 'course-hifz-uuid',
          courseName: 'Hifz-ul-Quran',
          nameEnglish: 'Hifz Memorization & Sabqi',
          nameUrdu: 'حفظ و سبقی و منزل',
          bookCount: 1,
        ),
      ];
}
