import 'package:flutter/widgets.dart';
import 'package:staff_app/core/l10n/app_strings.dart';

/// Immutable Domain Entity representing an academic subject textbook pairing:
/// Main Original Book (اصل متن) + Translation & Commentary (ترجمہ و شرح).
class EBookBundleModel {
  const EBookBundleModel({
    required this.id,
    required this.courseId,
    required this.classId,
    required this.subjectName,
    this.subjectUrduName = '',
    this.subjectHindiName = '',
    required this.subjectCode,
    required this.department,
    required this.mainBookTitle,
    required this.mainBookUrduTitle,
    this.mainBookHindiTitle = '',
    required this.mainBookAuthor,
    required this.mainBookLanguage,
    required this.mainBookPages,
    required this.mainBookBadge,
    required this.transBookTitle,
    required this.transBookUrduTitle,
    this.transBookHindiTitle = '',
    required this.transBookAuthor,
    required this.transBookLanguage,
    required this.transBookPages,
    required this.transBookBadge,
  });

  final String id;
  final String courseId;
  final String classId;
  final String subjectName;
  final String subjectUrduName;
  final String subjectHindiName;
  final String subjectCode;
  final String department;

  // 1. Original / Main Book (اصل کتاب / متن)
  final String mainBookTitle;
  final String mainBookUrduTitle;
  final String mainBookHindiTitle;
  final String mainBookAuthor;
  final String mainBookLanguage;
  final int mainBookPages;
  final String mainBookBadge;

  // 2. Translation & Sharh (ترجمہ و تشریح)
  final String transBookTitle;
  final String transBookUrduTitle;
  final String transBookHindiTitle;
  final String transBookAuthor;
  final String transBookLanguage;
  final int transBookPages;
  final String transBookBadge;

  String localizedSubject([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'ebook_subject_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      if (subjectUrduName.isNotEmpty) return subjectUrduName;
    }
    if (langCode == 'hi' && subjectHindiName.isNotEmpty) {
      return subjectHindiName;
    }
    return subjectName;
  }

  String localizedMainTitle([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'ebook_main_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      if (mainBookUrduTitle.isNotEmpty) return mainBookUrduTitle;
    }
    if (langCode == 'hi' && mainBookHindiTitle.isNotEmpty) {
      return mainBookHindiTitle;
    }
    return mainBookTitle;
  }

  String localizedTransTitle([bool isRtl = false, String? langCode, BuildContext? context]) {
    if (context != null) {
      final trKey = 'ebook_trans_$id';
      final val = context.tr(trKey);
      if (val != trKey) return val;
      langCode ??= context.currentLanguageCode;
    }
    if (langCode == 'ur' || (langCode == null && isRtl)) {
      if (transBookUrduTitle.isNotEmpty) return transBookUrduTitle;
    }
    if (langCode == 'hi' && transBookHindiTitle.isNotEmpty) {
      return transBookHindiTitle;
    }
    return transBookTitle;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EBookBundleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
