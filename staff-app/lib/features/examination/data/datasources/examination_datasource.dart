import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';
import 'package:staff_app/features/examination/domain/models/question_paper_model.dart';
import 'package:staff_app/features/examination/domain/models/student_marks_entry_model.dart';

/// Institutional Datasource for Examination Hierarchy, Question Bank & Marks Entry
class ExaminationDatasource {
  const ExaminationDatasource();

  // ---------------------------------------------------------------------------
  // 1. Academic Hierarchy (Courses ➔ Classes ➔ Subjects ➔ Books)
  // ---------------------------------------------------------------------------
  static const List<CourseEntity> mockCourses = [
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
      id: 'crs_hifz',
      nameEnglish: 'Hifz-ul-Quran & Tajweed',
      nameUrdu: 'شعبۂ حفظ القرآن و تجوید',
      code: 'HFZ',
    ),
    CourseEntity(
      id: 'crs_fazilat',
      nameEnglish: 'Fazilat Specialization',
      nameUrdu: 'شعبۂ فضیلت و تخصص',
      code: 'FAZ',
    ),
  ];

  static const List<ClassEntity> mockClasses = [
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
    // Hifz
    ClassEntity(
      id: 'cls_hfz_1',
      courseId: 'crs_hifz',
      nameEnglish: 'Hifz Senior Group',
      nameUrdu: 'حفظ سالِ آخر',
      section: 'Hall 1',
    ),
    // Fazilat
    ClassEntity(
      id: 'cls_faz_1',
      courseId: 'crs_fazilat',
      nameEnglish: 'Fazilat Final Year',
      nameUrdu: 'دورۂ حدیث شریف',
      section: 'Main Wing',
    ),
  ];

  static const List<SubjectEntity> mockSubjects = [
    // Aalimiyat 1st year subjects
    SubjectEntity(
      id: 'sub_fiqh_1',
      classId: 'cls_aal_1',
      nameEnglish: 'Islamic Jurisprudence (Fiqh)',
      nameUrdu: 'فقہ اسلامی و اصولِ فقہ',
      code: 'FIQH-101',
    ),
    SubjectEntity(
      id: 'sub_arb_1',
      classId: 'cls_aal_1',
      nameEnglish: 'Arabic Syntax & Nahw',
      nameUrdu: 'عربی گرامر و نحو',
      code: 'ARAB-101',
    ),
    // Class 10th subjects
    SubjectEntity(
      id: 'sub_eng_10',
      classId: 'cls_sec_10',
      nameEnglish: 'English Literature',
      nameUrdu: 'انگریزی ادب',
      code: 'ENG-10',
    ),
    SubjectEntity(
      id: 'sub_math_10',
      classId: 'cls_sec_10',
      nameEnglish: 'Advanced Mathematics',
      nameUrdu: 'ریاضیات',
      code: 'MATH-10',
    ),
    SubjectEntity(
      id: 'sub_urdu_10',
      classId: 'cls_sec_10',
      nameEnglish: 'Urdu Literature & Essay',
      nameUrdu: 'اردو ادب و انشا',
      code: 'URDU-10',
    ),
    // Class 9th subjects
    SubjectEntity(
      id: 'sub_sci_9',
      classId: 'cls_sec_9',
      nameEnglish: 'General Science',
      nameUrdu: 'سائنس',
      code: 'SCI-9',
    ),
  ];

  static const List<BookEntity> mockBooks = [
    // Fiqh books for Aalimiyat 1st year
    BookEntity(
      id: 'bk_noor_ul_izah',
      subjectId: 'sub_fiqh_1',
      nameEnglish: 'Noor-ul-Izah (Kitab-ut-Taharah & Salah)',
      nameUrdu: 'نور الایضاح (کتاب الطہارة والصلاة)',
      maxMarks: 100,
      passMarks: 33,
    ),
    BookEntity(
      id: 'bk_qudoori_1',
      subjectId: 'sub_fiqh_1',
      nameEnglish: 'Mukhtasar Al-Qudoori (Part 1)',
      nameUrdu: 'مختصر القدوری (جلد اول)',
      maxMarks: 100,
      passMarks: 33,
    ),
    // Arabic books
    BookEntity(
      id: 'bk_hidayatun_nahw',
      subjectId: 'sub_arb_1',
      nameEnglish: 'Hidayat-un-Nahw (Grammar)',
      nameUrdu: 'ہدایت النحو',
      maxMarks: 100,
      passMarks: 33,
    ),
    // Class 10th books
    BookEntity(
      id: 'bk_math_ncert',
      subjectId: 'sub_math_10',
      nameEnglish: 'NCERT Mathematics (Standard 10)',
      nameUrdu: 'ریاضیات برائے جماعت دہم',
      maxMarks: 100,
      passMarks: 33,
    ),
    BookEntity(
      id: 'bk_urdu_adab_10',
      subjectId: 'sub_urdu_10',
      nameEnglish: 'Urdu Nisab (Jaan Pehchan Part 2)',
      nameUrdu: 'اردو نصاب (جان پہچان حصہ دوم)',
      maxMarks: 100,
      passMarks: 33,
    ),
  ];

  // ---------------------------------------------------------------------------
  // 2. Questions Database / Repository
  // ---------------------------------------------------------------------------
  static final List<QuestionPaperItem> _stagedQuestions = [
    QuestionPaperItem(
      id: 'q_001',
      bookId: 'bk_noor_ul_izah',
      bookName: 'Noor-ul-Izah',
      questionText: 'وضو کے فرائض اور سنن تفصیل کے ساتھ تحریر فرمائیں؟',
      marks: 10,
      pageNo: 14,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuestionPaperItem(
      id: 'q_002',
      bookId: 'bk_noor_ul_izah',
      bookName: 'Noor-ul-Izah',
      questionText: 'پانی کی مختلف اقسام اور ان سے پاکی حاصل کرنے کا شرعی حکم کیا ہے؟',
      marks: 15,
      pageNo: 28,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // ---------------------------------------------------------------------------
  // 3. Student Marks Evaluation Roster (With Attendance-Based Absentee Lock)
  // ---------------------------------------------------------------------------
  static final Map<String, List<StudentMarksRow>> _classStudentRosters = {
    'cls_aal_1': [
      const StudentMarksRow(
        studentId: 'std_001',
        rollNo: '101',
        name: 'Mohammad Zaid',
        admissionNo: 'ADM-2024-0101',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: false,
        obtainedMarks: 84,
        maxMarks: 100,
      ),
      const StudentMarksRow(
        studentId: 'std_002',
        rollNo: '102',
        name: 'Abdullah Khan',
        admissionNo: 'ADM-2024-0102',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: true, // STRICT LAW: Absent on exam date -> input disabled
        obtainedMarks: null,
        maxMarks: 100,
        statusRemarks: 'Marked Absent in Hall Roll Call',
      ),
      const StudentMarksRow(
        studentId: 'std_003',
        rollNo: '103',
        name: 'Fatima Zahra',
        admissionNo: 'ADM-2024-0103',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: false,
        obtainedMarks: 91,
        maxMarks: 100,
      ),
      const StudentMarksRow(
        studentId: 'std_004',
        rollNo: '104',
        name: 'Umar Farooq',
        admissionNo: 'ADM-2024-0104',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: false,
        obtainedMarks: 76,
        maxMarks: 100,
      ),
      const StudentMarksRow(
        studentId: 'std_005',
        rollNo: '105',
        name: 'Aisha Siddiqua',
        admissionNo: 'ADM-2024-0105',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: true, // STRICT LAW: Absent on exam date -> input disabled
        obtainedMarks: null,
        maxMarks: 100,
        statusRemarks: 'Medical Leave / Absent',
      ),
      const StudentMarksRow(
        studentId: 'std_006',
        rollNo: '106',
        name: 'Bilal Ahmad',
        admissionNo: 'ADM-2024-0106',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: false,
        obtainedMarks: null, // Pending evaluation
        maxMarks: 100,
      ),
      const StudentMarksRow(
        studentId: 'std_007',
        rollNo: '107',
        name: 'Zubair Qasmi',
        admissionNo: 'ADM-2024-0107',
        registeredClass: 'Aalimiyat 1st Year',
        isAbsent: false,
        obtainedMarks: null, // Pending evaluation
        maxMarks: 100,
      ),
    ],
    'cls_sec_10': [
      const StudentMarksRow(
        studentId: 'std_010',
        rollNo: '201',
        name: 'Tariq Jameel',
        admissionNo: 'ADM-2024-0201',
        registeredClass: 'Class 10th (Matric)',
        isAbsent: false,
        obtainedMarks: 88,
        maxMarks: 100,
      ),
      const StudentMarksRow(
        studentId: 'std_011',
        rollNo: '202',
        name: 'Salma Parveen',
        admissionNo: 'ADM-2024-0202',
        registeredClass: 'Class 10th (Matric)',
        isAbsent: true, // Absent
        obtainedMarks: null,
        maxMarks: 100,
      ),
      const StudentMarksRow(
        studentId: 'std_012',
        rollNo: '203',
        name: 'Rehan Siddiqui',
        admissionNo: 'ADM-2024-0203',
        registeredClass: 'Class 10th (Matric)',
        isAbsent: false,
        obtainedMarks: null,
        maxMarks: 100,
      ),
    ],
  };

  // ---------------------------------------------------------------------------
  // Methods
  // ---------------------------------------------------------------------------
  List<CourseEntity> getCourses() => mockCourses;

  List<ClassEntity> getClasses(String courseId) =>
      mockClasses.where((c) => c.courseId == courseId).toList();

  List<SubjectEntity> getSubjects(String classId) =>
      mockSubjects.where((s) => s.classId == classId).toList();

  List<BookEntity> getBooks(String subjectId) =>
      mockBooks.where((b) => b.subjectId == subjectId).toList();

  List<QuestionPaperItem> getQuestionsForBook(String bookId) =>
      _stagedQuestions.where((q) => q.bookId == bookId).toList();

  void uploadQuestion(QuestionPaperItem item) {
    _stagedQuestions.insert(0, item);
  }

  List<StudentMarksRow> getStudentRoster(String classId, {int maxMarks = 100}) {
    final list = _classStudentRosters[classId] ?? _classStudentRosters['cls_aal_1']!;
    return list.map((s) => s.copyWith(maxMarks: maxMarks)).toList();
  }

  Future<bool> saveStudentMarksBatch({
    required String bookId,
    required List<StudentMarksRow> rows,
  }) async {
    // Simulate server write latency
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
