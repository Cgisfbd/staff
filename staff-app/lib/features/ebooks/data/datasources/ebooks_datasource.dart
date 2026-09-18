import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:staff_app/features/ebooks/domain/models/ebook_bundle_model.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';

/// Institutional Datasource for E-Books Curriculum, Dual-Book Pairings & PDF Generation
class EbooksDatasource {
  const EbooksDatasource();

  // 1. Available Courses
  static const List<CourseEntity> courses = [
    CourseEntity(
      id: 'crs_aalimiyat',
      nameEnglish: 'Aalimiyat Degree Course',
      nameUrdu: 'شعبۂ عالمیات و علومِ دینیہ',
      code: 'AAL',
    ),
    CourseEntity(
      id: 'crs_secondary',
      nameEnglish: 'Secondary Modern Curriculum',
      nameUrdu: 'شعبۂ تعلیمِ ثانوی (سکینڈری)',
      code: 'SEC',
    ),
    CourseEntity(
      id: 'crs_fazilat',
      nameEnglish: 'Fazilat Specialization (Hadith)',
      nameUrdu: 'شعبۂ فضیلت و تخصص',
      code: 'FAZ',
    ),
    CourseEntity(
      id: 'crs_hifz',
      nameEnglish: 'Hifz-ul-Quran & Tajweed',
      nameUrdu: 'شعبۂ حفظ القرآن و تجوید',
      code: 'HFZ',
    ),
  ];

  // 2. Available Classes mapped to Courses
  static const List<ClassEntity> classes = [
    // Aalimiyat
    ClassEntity(
      id: 'cls_aal_1',
      courseId: 'crs_aalimiyat',
      nameEnglish: 'Aalimiyat 1st Year',
      nameUrdu: 'سال اول عالمیات',
      section: 'Section A',
    ),
    ClassEntity(
      id: 'cls_aal_2',
      courseId: 'crs_aalimiyat',
      nameEnglish: 'Aalimiyat 2nd Year',
      nameUrdu: 'سال دوم عالمیات',
      section: 'Section B',
    ),
    // Secondary
    ClassEntity(
      id: 'cls_sec_10',
      courseId: 'crs_secondary',
      nameEnglish: 'Class 10th (Matric)',
      nameUrdu: 'دسویں جماعت (میٹرک)',
      section: 'Section A',
    ),
    ClassEntity(
      id: 'cls_sec_9',
      courseId: 'crs_secondary',
      nameEnglish: 'Class 9th',
      nameUrdu: 'نویں جماعت',
      section: 'Section B',
    ),
    // Fazilat
    ClassEntity(
      id: 'cls_faz_1',
      courseId: 'crs_fazilat',
      nameEnglish: 'Fazilat Final Year (Dawrah)',
      nameUrdu: 'دورۂ حدیث شریف',
      section: 'Main Wing',
    ),
    // Hifz
    ClassEntity(
      id: 'cls_hfz_1',
      courseId: 'crs_hifz',
      nameEnglish: 'Hifz Senior Group',
      nameUrdu: 'حفظ سالِ آخر',
      section: 'Hall 1',
    ),
  ];

  // 3. Dual-Book Pairings Catalog (Main Original + Translation & Sharh)
  static const List<EBookBundleModel> bundles = [
    // --- Aalimiyat 1st Year ---
    EBookBundleModel(
      id: 'bk_aal1_fiqh',
      courseId: 'crs_aalimiyat',
      classId: 'cls_aal_1',
      subjectName: 'Islamic Jurisprudence (Fiqh)',
      subjectUrduName: 'علم الفقہ و اصولِ شریعت',
      subjectCode: 'FIQH-101',
      department: 'Fiqh & Usul',
      mainBookTitle: 'Mukhtasar al-Quduri (Arabic Matan)',
      mainBookUrduTitle: 'مختصر القدوری (عربی متن)',
      mainBookAuthor: 'Imam Abu al-Husayn al-Quduri (d. 428 AH)',
      mainBookLanguage: 'Arabic Original',
      mainBookPages: 284,
      mainBookBadge: 'ORIGINAL MATAN',
      transBookTitle: 'Tasheel al-Quduri (Urdu Sharh & Hashiyah)',
      transBookUrduTitle: 'تسهیل القدوری (اردو ترجمہ و تشریح)',
      transBookAuthor: 'Maulana Aizaz Ali & Scholars Council',
      transBookLanguage: 'Urdu Translation',
      transBookPages: 420,
      transBookBadge: 'TARJUMA & SHARH',
    ),
    EBookBundleModel(
      id: 'bk_aal1_nahw',
      courseId: 'crs_aalimiyat',
      classId: 'cls_aal_1',
      subjectName: 'Arabic Syntax & Grammar (Nahw)',
      subjectUrduName: 'علم النحو و قواعدِ عربی',
      subjectCode: 'NAHW-102',
      department: 'Arabic Linguistics',
      mainBookTitle: 'Hidayatun Nahw (Classical Arabic)',
      mainBookUrduTitle: 'ہدایۃ النحو (عربی متن)',
      mainBookAuthor: 'Siraj al-Din Uthman al-Sajawandi',
      mainBookLanguage: 'Arabic Original',
      mainBookPages: 156,
      mainBookBadge: 'ORIGINAL MATAN',
      transBookTitle: 'Al-Misbah Sharh Hidayatun Nahw',
      transBookUrduTitle: 'المصباح شرح ہدایۃ النحو (اردو)',
      transBookAuthor: 'Mufti Saeed Ahmad Palanpuri',
      transBookLanguage: 'Urdu Commentary',
      transBookPages: 248,
      transBookBadge: 'TARJUMA & SHARH',
    ),
    EBookBundleModel(
      id: 'bk_aal1_sarf',
      courseId: 'crs_aalimiyat',
      classId: 'cls_aal_1',
      subjectName: 'Arabic Morphology (Sarf)',
      subjectUrduName: 'علم الصرف و ابواب اللغۃ',
      subjectCode: 'SARF-103',
      department: 'Arabic Linguistics',
      mainBookTitle: 'Ilm-us-Seegha (Persian & Arabic Matan)',
      mainBookUrduTitle: 'علم الصیغہ (متنِ کامل)',
      mainBookAuthor: 'Mufti Inayat Ahmad Kakorwi',
      mainBookLanguage: 'Arabic / Persian',
      mainBookPages: 128,
      mainBookBadge: 'ORIGINAL MATAN',
      transBookTitle: 'Irshad-us-Seegha (Detailed Urdu Guide)',
      transBookUrduTitle: 'ارشاد الصیغہ شرح علم الصیغہ',
      transBookAuthor: 'Maulana Mushtaq Ahmad Charthawali',
      transBookLanguage: 'Urdu Translation',
      transBookPages: 196,
      transBookBadge: 'TARJUMA & SHARH',
    ),

    // --- Aalimiyat 2nd Year ---
    EBookBundleModel(
      id: 'bk_aal2_usul',
      courseId: 'crs_aalimiyat',
      classId: 'cls_aal_2',
      subjectName: 'Principles of Jurisprudence (Usul)',
      subjectUrduName: 'اصولِ فقہ و استنباط',
      subjectCode: 'USUL-201',
      department: 'Fiqh & Usul',
      mainBookTitle: 'Usul al-Shashi (Arabic Matan)',
      mainBookUrduTitle: 'اصول الشاشی (عربی متن)',
      mainBookAuthor: 'Nizam al-Din Ishaq al-Shashi',
      mainBookLanguage: 'Arabic Original',
      mainBookPages: 180,
      mainBookBadge: 'ORIGINAL MATAN',
      transBookTitle: 'Husool al-Hawashi Sharh Usul al-Shashi',
      transBookUrduTitle: 'حصول الحواشی شرح اصول الشاشی',
      transBookAuthor: 'Allama Faiz al-Hasan Gangohi',
      transBookLanguage: 'Urdu Commentary',
      transBookPages: 310,
      transBookBadge: 'TARJUMA & SHARH',
    ),
    EBookBundleModel(
      id: 'bk_aal2_hadith',
      courseId: 'crs_aalimiyat',
      classId: 'cls_aal_2',
      subjectName: 'Hadith Studies & Prophetic Traditions',
      subjectUrduName: 'حدیث شریف و سننِ مبارکہ',
      subjectCode: 'HDTH-202',
      department: 'Hadith Studies',
      mainBookTitle: 'Riyadh us-Saliheen (Arabic Text)',
      mainBookUrduTitle: 'ریاض الصالحین (عربی متن)',
      mainBookAuthor: 'Imam Yahya ibn Sharaf al-Nawawi',
      mainBookLanguage: 'Arabic Original',
      mainBookPages: 640,
      mainBookBadge: 'ORIGINAL MATAN',
      transBookTitle: 'Zad ut-Talibeen & Urdu Commentary',
      transBookUrduTitle: 'زاد الطالبین مع اردو تشریح',
      transBookAuthor: 'Maulana Ashiq Ilahi Bulandshahri',
      transBookLanguage: 'Urdu Translation',
      transBookPages: 340,
      transBookBadge: 'TARJUMA & SHARH',
    ),

    // --- Secondary Matric (Class 10th) ---
    EBookBundleModel(
      id: 'bk_sec10_phy',
      courseId: 'crs_secondary',
      classId: 'cls_sec_10',
      subjectName: 'Secondary Physics & Mechanics',
      subjectUrduName: 'طبیعیات و میکانیات',
      subjectCode: 'PHY-10',
      department: 'Physical Sciences',
      mainBookTitle: 'Principles of Physics (English Standard)',
      mainBookUrduTitle: 'اصولِ طبیعیات (انگریزی ایڈیشن)',
      mainBookAuthor: 'National Science Curriculum Board',
      mainBookLanguage: 'English Edition',
      mainBookPages: 295,
      mainBookBadge: 'TEXTBOOK (EN)',
      transBookTitle: 'Physics Comprehensive Urdu Translation',
      transBookUrduTitle: 'طبیعیات جامع اردو ترجمہ و گائیڈ',
      transBookAuthor: 'Barkat Tech Academic Translation Wing',
      transBookLanguage: 'Urdu Translation',
      transBookPages: 315,
      transBookBadge: 'URDU MEDIUM',
    ),
    EBookBundleModel(
      id: 'bk_sec10_math',
      courseId: 'crs_secondary',
      classId: 'cls_sec_10',
      subjectName: 'Advanced Secondary Mathematics',
      subjectUrduName: 'ریاضیات و حسابی علوم',
      subjectCode: 'MTH-10',
      department: 'Mathematical Sciences',
      mainBookTitle: 'Advanced Secondary Mathematics',
      mainBookUrduTitle: 'اعلیٰ ثانوی ریاضیات (انگریزی)',
      mainBookAuthor: 'NCERT & State Academic Council',
      mainBookLanguage: 'English Edition',
      mainBookPages: 380,
      mainBookBadge: 'TEXTBOOK (EN)',
      transBookTitle: 'Riyazi Hal-Shuda Guide & Solutions',
      transBookUrduTitle: 'ریاضی حل شدہ گائیڈ و تشریحات',
      transBookAuthor: 'Faculty of Mathematical Sciences',
      transBookLanguage: 'Urdu Translation',
      transBookPages: 410,
      transBookBadge: 'URDU MEDIUM',
    ),

    // --- Fazilat Final Year ---
    EBookBundleModel(
      id: 'bk_faz1_bukhari',
      courseId: 'crs_fazilat',
      classId: 'cls_faz_1',
      subjectName: 'Sahih al-Bukhari (Al-Jami al-Sahih)',
      subjectUrduName: 'صحیح البخاری الشریف',
      subjectCode: 'BUKH-401',
      department: 'Higher Hadith Council',
      mainBookTitle: 'Al-Jami al-Sahih (Sahih al-Bukhari)',
      mainBookUrduTitle: 'صحیح البخاری (عربی متنِ کامل)',
      mainBookAuthor: 'Imam Muhammad ibn Ismail al-Bukhari',
      mainBookLanguage: 'Arabic Original',
      mainBookPages: 1140,
      mainBookBadge: 'ORIGINAL MATAN',
      transBookTitle: 'Nasr al-Bari Sharh Sahih al-Bukhari',
      transBookUrduTitle: 'نصر الباری شرح اردو صحیح البخاری',
      transBookAuthor: 'Allama Shabbir Ahmad Usmani',
      transBookLanguage: 'Urdu Sharh',
      transBookPages: 1420,
      transBookBadge: 'TARJUMA & SHARH',
    ),

    // --- Hifz Senior Group ---
    EBookBundleModel(
      id: 'bk_hfz1_tajweed',
      courseId: 'crs_hifz',
      classId: 'cls_hfz_1',
      subjectName: 'Tajweed Rules & Qiraat Science',
      subjectUrduName: 'علم التجوید و فنِ قرأت',
      subjectCode: 'TJW-101',
      department: 'Quranic Sciences',
      mainBookTitle: 'Al-Jazariyyah (Arabic Tajweed Poem)',
      mainBookUrduTitle: 'المقدمة الجزریہ فی علم التجوید',
      mainBookAuthor: 'Imam Muhammad Ibn al-Jazari',
      mainBookLanguage: 'Arabic Original',
      mainBookPages: 48,
      mainBookBadge: 'ORIGINAL POEM',
      transBookTitle: 'Ahkam al-Tajweed (Detailed Urdu Sharh)',
      transBookUrduTitle: 'احکام التجوید شرح المقدمۃ الجزریہ',
      transBookAuthor: 'Qari Muhammad Idris & Tajweed Board',
      transBookLanguage: 'Urdu Translation',
      transBookPages: 164,
      transBookBadge: 'TARJUMA & SHARH',
    ),
  ];

  static List<ClassEntity> getClassesForCourse(String courseId) {
    return classes.where((c) => c.courseId == courseId).toList();
  }

  static List<EBookBundleModel> getBooksForClass(String courseId, String classId) {
    return bundles
        .where((b) => b.courseId == courseId && b.classId == classId)
        .toList();
  }

  /// Dynamic Institutional PDF Document Generator for either Original or Translation
  static Future<Uint8List> generateBookPdf({
    required String title,
    required String author,
    required String subject,
    required String editionBadge,
    required String language,
    required int totalPages,
    required bool isTranslation,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Top Institutional Border Box
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.amber800, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TALEEMONE INSTITUTIONAL E-LIBRARY',
                          style: const pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.amber900,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Academic Curriculum & E-Book Repository • Barkat Tech',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: isTranslation ? PdfColors.green50 : PdfColors.amber50,
                        border: pw.Border.all(
                          color: isTranslation ? PdfColors.green800 : PdfColors.amber800,
                          width: 1,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        editionBadge,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: isTranslation ? PdfColors.green900 : PdfColors.amber900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Centered Book Title & Metadata
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      title,
                      style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Department: $subject',
                      style: const pw.TextStyle(fontSize: 13, color: PdfColors.amber900, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Author / Commentator: $author',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 14),
                    pw.Container(
                      width: 180,
                      height: 1.5,
                      color: PdfColors.amber600,
                    ),
                    pw.SizedBox(height: 14),
                    pw.Text(
                      'Language: $language • Volume Pages: $totalPages',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Verification Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Verified Institutional Textbook Copy',
                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      'Document Security ID: BAR-EBOOK-${totalPages}P',
                      style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
