import 'package:equatable/equatable.dart';

/// Single Subject in the Academic Catalog
class CatalogSubject extends Equatable {
  const CatalogSubject({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.books,
  });

  final String id;
  final String nameEn;
  final String nameUr;
  final List<String> books;

  @override
  List<Object?> get props => [id, nameEn, nameUr, books];
}

/// Single Class in the Academic Catalog
class CatalogClass extends Equatable {
  const CatalogClass({
    required this.id,
    required this.courseId,
    required this.nameEn,
    required this.nameUr,
    required this.section,
    required this.subjects,
  });

  final String id;
  final String courseId;
  final String nameEn;
  final String nameUr;
  final String section;
  final List<CatalogSubject> subjects;

  @override
  List<Object?> get props => [id, courseId, nameEn, nameUr, section, subjects];
}

/// Single Course in the Academic Catalog
class CatalogCourse extends Equatable {
  const CatalogCourse({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.code,
    required this.classes,
  });

  final String id;
  final String nameEn;
  final String nameUr;
  final String code;
  final List<CatalogClass> classes;

  @override
  List<Object?> get props => [id, nameEn, nameUr, code, classes];
}

/// Master Institutional Catalog for 4-Tier Academic Hierarchy:
/// Course ➔ Class ➔ Subject ➔ Books
class StaffAcademicCatalog {
  const StaffAcademicCatalog._();

  static const List<CatalogCourse> courses = [
    // 1. Aalimiyat Degree Course
    CatalogCourse(
      id: 'crs_aalimiyat',
      nameEn: 'Aalimiyat Degree Course',
      nameUr: 'شعبۂ عالمیات و علومِ دینیہ',
      code: 'AAL',
      classes: [
        CatalogClass(
          id: 'cls_aal_1',
          courseId: 'crs_aalimiyat',
          nameEn: 'Aalimiyat 1st Year',
          nameUr: 'سال اول عالمیات',
          section: 'Section A',
          subjects: [
            CatalogSubject(
              id: 'sub_aal1_fiqh',
              nameEn: 'Islamic Jurisprudence (Fiqh)',
              nameUr: 'فقہ اسلامی و اصولِ فقہ',
              books: [
                'Mukhtasar Al-Qudoori (Part 1)',
                'Noor-ul-Izah (Kitab-ut-Taharah & Salah)',
                'Kanz-ud-Daqaiq (Taharah)',
                'Fatawa Rahimiya (Intro)',
              ],
            ),
            CatalogSubject(
              id: 'sub_aal1_nahw',
              nameEn: 'Arabic Syntax & Grammar (Nahw & Sarf)',
              nameUr: 'عربی گرامر، نحو و صرف',
              books: [
                'Hidayat-un-Nahw (Grammar)',
                'Mizaan-us-Sarf',
                'Munshaib (Sarf)',
                'Sharh Mi’ata Aamil',
                'Ilm-us-Seegha',
              ],
            ),
            CatalogSubject(
              id: 'sub_aal1_adab',
              nameEn: 'Arabic Literature & Translation (Adab)',
              nameUr: 'ادب عربی و ترجمہ نگاری',
              books: [
                'Tareeqat-ul-Asriyyah (Part 1)',
                'Al-Qira’at-ur-Rashidah (Part 1)',
                'Tamreen-ut-Talib (Insha)',
              ],
            ),
            CatalogSubject(
              id: 'sub_aal1_seerat',
              nameEn: 'Seerat & Islamic History',
              nameUr: 'سیرت النبی و تاریخ اسلام',
              books: [
                'Seerat-un-Nabi (Allama Shibli)',
                'Tareekh-e-Islam (Mawlana Akbar Shah)',
                'Uswa-e-Rasool-e-Akram',
              ],
            ),
          ],
        ),
        CatalogClass(
          id: 'cls_aal_2',
          courseId: 'crs_aalimiyat',
          nameEn: 'Aalimiyat 2nd Year',
          nameUr: 'سال دوم عالمیات',
          section: 'Section B',
          subjects: [
            CatalogSubject(
              id: 'sub_aal2_fiqh',
              nameEn: 'Advanced Fiqh (Hidayah & Fatawa)',
              nameUr: 'فقہ ثانی (ہدایہ اول و ثانی)',
              books: [
                'Al-Hidayah (Awwalain - Fiqh)',
                'Kanz-ud-Daqaiq (Complete)',
                'Radd-ul-Muhtar (Selected Fawaid)',
              ],
            ),
            CatalogSubject(
              id: 'sub_aal2_nahw_balaghat',
              nameEn: 'Advanced Nahw & Balaghat (Rhetoric)',
              nameUr: 'نحوِ عالی و علم البلاغت',
              books: [
                'Al-Qafiyah (Ibn-ul-Hajib)',
                'Duroos-ul-Balaghah',
                'Talkhees-ul-Miftah',
                'Sharh Jami (Selected Fasl)',
              ],
            ),
            CatalogSubject(
              id: 'sub_aal2_adab',
              nameEn: 'Classical Arabic Literature',
              nameUr: 'ادبِ عالی و نثری شاہکار',
              books: [
                'Nafhat-ul-Arab (Literature)',
                'Maqamat-ul-Hariri (Selections)',
                'Diwan-e-Hamasah (Abu Tammam)',
              ],
            ),
            CatalogSubject(
              id: 'sub_aal2_usul',
              nameEn: 'Usul-ul-Fiqh & Logic (Mantiq)',
              nameUr: 'اصولِ فقہ و علم المنطق',
              books: [
                'Usul Ash-Shashi',
                'Noor-ul-Anwar',
                'Sharh Tahzeeb (Mantiq)',
                'As-Sullam-ul-Munawraq',
              ],
            ),
          ],
        ),
      ],
    ),

    // 2. Fazilat Specialization
    CatalogCourse(
      id: 'crs_fazilat',
      nameEn: 'Fazilat Specialization (Daura-e-Hadith)',
      nameUr: 'شعبۂ فضیلت و تخصص (دورۂ حدیث شریف)',
      code: 'FAZ',
      classes: [
        CatalogClass(
          id: 'cls_faz_1',
          courseId: 'crs_fazilat',
          nameEn: 'Fazilat Final Year',
          nameUr: 'دورۂ حدیث شریف',
          section: 'Main Wing',
          subjects: [
            CatalogSubject(
              id: 'sub_faz_bukhari',
              nameEn: 'Sahih Al-Bukhari (جامع صحیح بخاری)',
              nameUr: 'صحیح البخاری شریف',
              books: [
                'Sahih Al-Bukhari (Jild 1 - Bad’ul Wahi)',
                'Sahih Al-Bukhari (Jild 2 - Maghazi & Fitan)',
                'Fath-ul-Bari (Marginal Reference)',
              ],
            ),
            CatalogSubject(
              id: 'sub_faz_muslim',
              nameEn: 'Sahih Muslim (صحیح مسلم)',
              nameUr: 'صحیح مسلم شریف',
              books: [
                'Sahih Muslim (Jild 1)',
                'Sahih Muslim (Jild 2)',
                'Al-Minhaj Sharh Sahih Muslim',
              ],
            ),
            CatalogSubject(
              id: 'sub_faz_sunan',
              nameEn: 'Sunan Collections (سنن اربعہ)',
              nameUr: 'سنن ابی داؤد، ترمذی و نسائی',
              books: [
                'Sunan Abi Dawud',
                'Jami’ At-Tirmidhi (Jild 1 & 2)',
                'Sunan An-Nasa’i (Al-Mujtaba)',
                'Sunan Ibn Majah',
              ],
            ),
            CatalogSubject(
              id: 'sub_faz_tafseer',
              nameEn: 'Advanced Tafseer & Usul-ut-Tafseer',
              nameUr: 'تفسیر بیضاوی و اصول تفسیر',
              books: [
                'Tafseer Al-Baydawi (Surah Baqarah)',
                'Al-Fawz-ul-Kabeer (Shah Waliullah)',
                'Tafseer Al-Jalalayn',
              ],
            ),
          ],
        ),
      ],
    ),

    // 3. Hifz-ul-Quran & Tajweed
    CatalogCourse(
      id: 'crs_hifz',
      nameEn: 'Hifz-ul-Quran & Tajweed',
      nameUr: 'شعبۂ حفظ القرآن و تجوید',
      code: 'HFZ',
      classes: [
        CatalogClass(
          id: 'cls_hfz_senior',
          courseId: 'crs_hifz',
          nameEn: 'Hifz Senior Group (Daur-e-Sabaq)',
          nameUr: 'حفظ سالِ آخر و دور',
          section: 'Hall 1',
          subjects: [
            CatalogSubject(
              id: 'sub_hfz_memorization',
              nameEn: 'Quran Memorization (حفظِ قرآن)',
              nameUr: 'حفظ قرآن و منزل دہرائی',
              books: [
                'Hifz-e-Quran (Sabaq Daur Part 1)',
                'Hifz-e-Quran (Amma Parah & Manzil)',
                'Hifz-e-Quran (Mukammal Daur - 30 Paras)',
              ],
            ),
            CatalogSubject(
              id: 'sub_hfz_tajweed',
              nameEn: 'Ilm-ut-Tajweed & Qira’at (علم التجوید)',
              nameUr: 'علم التجوید و حسن قرات',
              books: [
                'Al-Jazariyyah (Muqaddimah)',
                'Tuhfat-ul-Atfal (Tajweed Rules)',
                'Fawaid-e-Makkiyyah (Qari Fateh)',
                'Khulasat-ut-Tajweed',
              ],
            ),
          ],
        ),
        CatalogClass(
          id: 'cls_hfz_junior',
          courseId: 'crs_hifz',
          nameEn: 'Hifz Junior Group (Nazirah & Sabaq)',
          nameUr: 'حفظ سالِ اول و ناظرہ',
          section: 'Hall 2',
          subjects: [
            CatalogSubject(
              id: 'sub_hfz_nazirah',
              nameEn: 'Nazirah Quran & Hifz Foundation',
              nameUr: 'ناظرہ قرآن و بنیادی حفظ',
              books: [
                'Noorani Qaida (Phonetics)',
                'Nazirah Quran (Amma Parah)',
                'Duas & Masnoon Prayers',
              ],
            ),
          ],
        ),
      ],
    ),

    // 4. Secondary Modern Curriculum
    CatalogCourse(
      id: 'crs_secondary',
      nameEn: 'Secondary Modern Curriculum',
      nameUr: 'شعبۂ تعلیمِ ثانوی (سکینڈری)',
      code: 'SEC',
      classes: [
        CatalogClass(
          id: 'cls_sec_10',
          courseId: 'crs_secondary',
          nameEn: 'Secondary Class 10th (Matric)',
          nameUr: 'دسویں جماعت (میٹرک)',
          section: 'Section A',
          subjects: [
            CatalogSubject(
              id: 'sub_sec10_math',
              nameEn: 'Mathematics (ریاضیات)',
              nameUr: 'ریاضیات برائے جماعت دہم',
              books: [
                'NCERT Mathematics (Standard 10)',
                'RD Sharma Exemplar Mathematics 10',
                'Mathematics Practice Papers',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec10_science',
              nameEn: 'General Science & Technology',
              nameUr: 'سائنس و تجرباتی علوم',
              books: [
                'NCERT Science & Technology 10',
                'Science Practical Lab Manual 10',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec10_english',
              nameEn: 'English Language & Literature',
              nameUr: 'انگریزی ادب و گرامر',
              books: [
                'First Flight English Reader 10',
                'Footprints Without Feet 10',
                'Applied English Grammar 10',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec10_urdu',
              nameEn: 'Urdu Literature & Composition',
              nameUr: 'اردو نصاب و انشا پردازی',
              books: [
                'Urdu Nisab (Jaan Pehchan Part 2)',
                'Urdu Qawaid-o-Insha 10',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec10_social',
              nameEn: 'Social Science & History',
              nameUr: 'سماجی علوم و تاریخ',
              books: [
                'India and the Contemporary World 10',
                'Democratic Politics 10',
                'Contemporary India Geography 10',
              ],
            ),
          ],
        ),
        CatalogClass(
          id: 'cls_sec_9',
          courseId: 'crs_secondary',
          nameEn: 'Secondary Class 9th',
          nameUr: 'نویں جماعت',
          section: 'Section B',
          subjects: [
            CatalogSubject(
              id: 'sub_sec9_math',
              nameEn: 'Mathematics',
              nameUr: 'ریاضی برائے جماعت نہم',
              books: [
                'NCERT Mathematics 9',
                'Mathematics Exemplar Problems 9',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec9_science',
              nameEn: 'General Science',
              nameUr: 'جنرل سائنس 9',
              books: [
                'NCERT Science 9',
                'Science Lab Manual 9',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec9_english',
              nameEn: 'English Language',
              nameUr: 'انگریزی نہم',
              books: [
                'Beehive English Reader 9',
                'Moments Supplementary Reader 9',
              ],
            ),
            CatalogSubject(
              id: 'sub_sec9_hindi',
              nameEn: 'Hindi / Regional Language',
              nameUr: 'ہندی زبان',
              books: [
                'Sparsh Hindi Part 1',
                'Sanchayan Part 1',
              ],
            ),
          ],
        ),
      ],
    ),

    // 5. Primary & Deeniyat
    CatalogCourse(
      id: 'crs_primary',
      nameEn: 'Primary Religious Studies & Deeniyat',
      nameUr: 'شعبۂ ابتدائی دینیات و اطفال',
      code: 'PRI',
      classes: [
        CatalogClass(
          id: 'cls_pri_5',
          courseId: 'crs_primary',
          nameEn: 'Primary Class 5th',
          nameUr: 'پرائمری پنجم',
          section: 'Section A',
          subjects: [
            CatalogSubject(
              id: 'sub_pri5_deeniyat',
              nameEn: 'Deeniyat & Islamic Etiquette',
              nameUr: 'دینیات، اخلاق و آداب',
              books: [
                'Ta’leem-ul-Islam (Part 1 to 4)',
                'Deeniyat Part 1 & 2',
                'Masnoon Duas & Daily Adab',
              ],
            ),
            CatalogSubject(
              id: 'sub_pri5_urdu',
              nameEn: 'Urdu Language & Reading',
              nameUr: 'اردو زبان و خوانی',
              books: [
                'Urdu Ki Pehli Kitab',
                'Urdu Ki Doosri Kitab',
                'Khushkhati & Writing Workbook',
              ],
            ),
            CatalogSubject(
              id: 'sub_pri5_general',
              nameEn: 'Basic Arithmetic & English',
              nameUr: 'بنیادی حساب و انگریزی',
              books: [
                'Basic English Alphabet & Phonics',
                'Primary Numbers & Math Workbook',
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  /// Find all classes across all courses
  static List<CatalogClass> get allClasses {
    return courses.expand((c) => c.classes).toList();
  }

  /// Find a Course by ID
  static CatalogCourse? findCourse(String courseId) {
    try {
      return courses.firstWhere((c) => c.id == courseId);
    } catch (_) {
      return null;
    }
  }

  /// Find a Class by Name or ID
  static CatalogClass? findClassByName(String className) {
    try {
      return allClasses.firstWhere(
        (c) => c.nameEn.toLowerCase() == className.toLowerCase() ||
               c.nameUr == className ||
               c.id == className,
      );
    } catch (_) {
      return null;
    }
  }
}
