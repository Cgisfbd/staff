import 'package:staff_app/features/courses/domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.simpleId,
    required super.nameEnglish,
    super.nameUrdu,
    super.description,
    required super.classCount,
    required super.subjectCount,
    required super.bookCount,
    required super.studentCount,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      simpleId: json['simpleId'] as int? ?? 1,
      nameEnglish: json['nameEnglish']?.toString() ?? json['name']?.toString() ?? 'Untitled Course',
      nameUrdu: json['nameUrdu']?.toString() ?? json['name_urdu']?.toString(),
      description: json['description']?.toString(),
      classCount: json['classCount'] as int? ?? json['classes_count'] as int? ?? 0,
      subjectCount: json['subjectCount'] as int? ?? json['subjects_count'] as int? ?? 0,
      bookCount: json['bookCount'] as int? ?? json['books_count'] as int? ?? 0,
      studentCount: json['studentCount'] as int? ?? json['students_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simpleId': simpleId,
      'nameEnglish': nameEnglish,
      'nameUrdu': nameUrdu,
      'description': description,
      'classCount': classCount,
      'subjectCount': subjectCount,
      'bookCount': bookCount,
      'studentCount': studentCount,
    };
  }

  CourseModel copyWith({
    String? id,
    int? simpleId,
    String? nameEnglish,
    String? nameUrdu,
    String? description,
    int? classCount,
    int? subjectCount,
    int? bookCount,
    int? studentCount,
  }) {
    return CourseModel(
      id: id ?? this.id,
      simpleId: simpleId ?? this.simpleId,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      description: description ?? this.description,
      classCount: classCount ?? this.classCount,
      subjectCount: subjectCount ?? this.subjectCount,
      bookCount: bookCount ?? this.bookCount,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  static final List<CourseModel> mockCourses = [
    const CourseModel(
      id: 'course-dars-e-nizami-uuid',
      simpleId: 1,
      nameEnglish: 'Dars-e-Nizami (Alimiyat & Fazilat)',
      nameUrdu: 'درس نظامی (عالمیت و فضیلت)',
      description: 'Comprehensive classical Islamic curriculum covering Arabic grammar, Fiqh, Hadith, Tafseer & Usul.',
      classCount: 8,
      subjectCount: 32,
      bookCount: 64,
      studentCount: 420,
    ),
    const CourseModel(
      id: 'course-hifz-uuid',
      simpleId: 2,
      nameEnglish: 'Hifz-ul-Quran (Tahfeez)',
      nameUrdu: 'حفظ القرآن الکریم',
      description: 'Complete memorization of the Holy Quran with Tajweed rules, revision and voice cultivation.',
      classCount: 6,
      subjectCount: 12,
      bookCount: 18,
      studentCount: 340,
    ),
    const CourseModel(
      id: 'course-tajweed-uuid',
      simpleId: 3,
      nameEnglish: 'Tajweed-wa-Qira\'at',
      nameUrdu: 'تجوید و قرأت سبعہ و عشرہ',
      description: 'Specialized phonetic articulation of Arabic letters and advanced Qira\'at recitation styles.',
      classCount: 4,
      subjectCount: 10,
      bookCount: 16,
      studentCount: 180,
    ),
    const CourseModel(
      id: 'course-primary-uuid',
      simpleId: 4,
      nameEnglish: 'Primary Islamic Schooling',
      nameUrdu: 'پرائمری دینی و عصری تعلیم',
      description: 'Integrated early foundational learning blending modern subjects (Maths, Science, English) with Deeniyat.',
      classCount: 5,
      subjectCount: 15,
      bookCount: 25,
      studentCount: 310,
    ),
  ];
}
