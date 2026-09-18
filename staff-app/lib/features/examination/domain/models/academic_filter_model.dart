import 'package:flutter/widgets.dart';
import 'package:staff_app/core/l10n/app_strings.dart';

/// Immutable Domain Entities for 4-tier Academic Hierarchy:
/// Course ➔ Class ➔ Subject ➔ Book
class CourseEntity {
  const CourseEntity({
    required this.id,
    required this.nameEnglish,
    required this.nameUrdu,
    this.nameHindi = '',
    required this.code,
  });

  final String id;
  final String nameEnglish;
  final String nameUrdu;
  final String nameHindi;
  final String code;

  String localizedName([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'course_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      return nameUrdu;
    }
    if (langCode == 'hi' && nameHindi.isNotEmpty) {
      return nameHindi;
    }
    return nameEnglish;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CourseEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ClassEntity {
  const ClassEntity({
    required this.id,
    required this.courseId,
    required this.nameEnglish,
    required this.nameUrdu,
    this.nameHindi = '',
    required this.section,
  });

  final String id;
  final String courseId;
  final String nameEnglish;
  final String nameUrdu;
  final String nameHindi;
  final String section;

  String localizedName([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'class_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    final base = (langCode == 'ur' || (langCode == null && isRtl))
        ? nameUrdu
        : ((langCode == 'hi' && nameHindi.isNotEmpty) ? nameHindi : nameEnglish);
    return '$base${section.isNotEmpty ? ' ($section)' : ''}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ClassEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class SubjectEntity {
  const SubjectEntity({
    required this.id,
    required this.classId,
    required this.nameEnglish,
    required this.nameUrdu,
    this.nameHindi = '',
    required this.code,
  });

  final String id;
  final String classId;
  final String nameEnglish;
  final String nameUrdu;
  final String nameHindi;
  final String code;

  String localizedName([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'subject_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      return nameUrdu;
    }
    if (langCode == 'hi' && nameHindi.isNotEmpty) {
      return nameHindi;
    }
    return nameEnglish;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SubjectEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class BookEntity {
  const BookEntity({
    required this.id,
    required this.subjectId,
    required this.nameEnglish,
    required this.nameUrdu,
    this.nameHindi = '',
    this.maxMarks = 100,
    this.passMarks = 33,
    this.term = 'FULL_YEAR',
  });

  final String id;
  final String subjectId;
  final String nameEnglish;
  final String nameUrdu;
  final String nameHindi;
  final int maxMarks;
  final int passMarks;
  final String term;

  String localizedName([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'book_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      return nameUrdu;
    }
    if (langCode == 'hi' && nameHindi.isNotEmpty) {
      return nameHindi;
    }
    return nameEnglish;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
