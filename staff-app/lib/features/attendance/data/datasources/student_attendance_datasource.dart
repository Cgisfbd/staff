import 'package:staff_app/features/attendance/domain/models/student_attendance_model.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';

/// Institutional Datasource for Class-wise Student Attendance Roster
class StudentAttendanceDatasource {
  const StudentAttendanceDatasource();

  static const List<CourseEntity> courses = [
    CourseEntity(
      id: 'crs_aalimiyat',
      nameEnglish: 'Aalimiyat Degree Course',
      nameUrdu: 'شعبۂ عالمیات و علومِ دینیہ',
      nameHindi: 'आलिमिया डिग्री कोर्स',
      code: 'AAL',
    ),
    CourseEntity(
      id: 'crs_secondary',
      nameEnglish: 'Secondary Modern Curriculum',
      nameUrdu: 'شعبۂ تعلیمِ ثانوی (سکینڈری)',
      nameHindi: 'माध्यमिक आधुनिक पाठ्यक्रम',
      code: 'SEC',
    ),
    CourseEntity(
      id: 'crs_hifz',
      nameEnglish: 'Hifz-ul-Quran & Tajweed',
      nameUrdu: 'شعبۂ حفظ القرآن و تجوید',
      nameHindi: 'हिफ़्ज़-उल-क़ुरआन और तजवीद',
      code: 'HFZ',
    ),
    CourseEntity(
      id: 'crs_fazilat',
      nameEnglish: 'Fazilat Specialization',
      nameUrdu: 'شعبۂ فضیلت و تخصص',
      nameHindi: 'फ़ज़ीलत विशेषज्ञता',
      code: 'FAZ',
    ),
  ];

  static const List<ClassEntity> classes = [
    // Aalimiyat
    ClassEntity(
      id: 'cls_aal_1',
      courseId: 'crs_aalimiyat',
      nameEnglish: 'Aalimiyat 1st Year',
      nameUrdu: 'سال اول عالمیات',
      nameHindi: 'आलिमिया प्रथम वर्ष',
      section: 'Section A',
    ),
    ClassEntity(
      id: 'cls_aal_2',
      courseId: 'crs_aalimiyat',
      nameEnglish: 'Aalimiyat 2nd Year',
      nameUrdu: 'سال دوم عالمیات',
      nameHindi: 'आलिमिया द्वितीय वर्ष',
      section: 'Section B',
    ),
    // Secondary
    ClassEntity(
      id: 'cls_sec_10',
      courseId: 'crs_secondary',
      nameEnglish: 'Class 10th (Matric)',
      nameUrdu: 'دسویں جماعت (میٹرک)',
      nameHindi: 'दसवीं कक्षा (मैट्रिक)',
      section: 'Section A',
    ),
    ClassEntity(
      id: 'cls_sec_9',
      courseId: 'crs_secondary',
      nameEnglish: 'Class 9th',
      nameUrdu: 'نویں جماعت',
      nameHindi: 'नौवीं कक्षा',
      section: 'Section B',
    ),
    // Hifz
    ClassEntity(
      id: 'cls_hfz_1',
      courseId: 'crs_hifz',
      nameEnglish: 'Hifz Senior Group',
      nameUrdu: 'حفظ سالِ آخر',
      nameHindi: 'हिफ़्ज़ वरिष्ठ समूह',
      section: 'Hall 1',
    ),
    // Fazilat
    ClassEntity(
      id: 'cls_faz_1',
      courseId: 'crs_fazilat',
      nameEnglish: 'Fazilat Final Year',
      nameUrdu: 'دورۂ حدیث شریف',
      nameHindi: 'फ़ज़ीलत अंतिम वर्ष (दौरा-ए-हदीस)',
      section: 'Main Wing',
    ),
  ];

  static final Map<String, List<StudentAttendanceItem>> _rosters = {
    'cls_aal_1': [
      const StudentAttendanceItem(
        studentId: 'std_aal1_001',
        rollNo: '101',
        name: 'Muhammad Zaid Qasmi',
        nameUrdu: 'محمد زید قاسمی',
        nameHindi: 'मोहम्मद ज़ैद क़ासिमी',
        admissionNo: 'ADM-2024-0101',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_002',
        rollNo: '102',
        name: 'Abdullah Nadwi',
        nameUrdu: 'عبد اللہ ندوی',
        nameHindi: 'अब्दुल्लाह नदवी',
        admissionNo: 'ADM-2024-0102',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.absent,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_003',
        rollNo: '103',
        name: 'Tariq Mahmood',
        nameUrdu: 'طارق محمود',
        nameHindi: 'तारिक महमूद',
        admissionNo: 'ADM-2024-0103',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.leave,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_004',
        rollNo: '104',
        name: 'Umar Farooq Shibli',
        nameUrdu: 'عمر فاروق شبلی',
        nameHindi: 'उमर फारूक शिबली',
        admissionNo: 'ADM-2024-0104',
        lastThreeDays: [
          HistoryDayStatus.absent,
          HistoryDayStatus.absent,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_005',
        rollNo: '105',
        name: 'Aisha Siddiqua',
        nameUrdu: 'عائشہ صدیقہ',
        nameHindi: 'आयशा सिद्दीका',
        admissionNo: 'ADM-2024-0105',
        lastThreeDays: [
          HistoryDayStatus.leave,
          HistoryDayStatus.leave,
          HistoryDayStatus.leave,
        ],
        status: AttendanceStatus.leave,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_006',
        rollNo: '106',
        name: 'Bilal Ahmad Madani',
        nameUrdu: 'بلال احمد مدنی',
        nameHindi: 'बिलाल अहमद मदनी',
        admissionNo: 'ADM-2024-0106',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_007',
        rollNo: '107',
        name: 'Zubair Ahmad Qasmi',
        nameUrdu: 'زبیر احمد قاسمی',
        nameHindi: 'ज़ुबैर अहमद क़ासिमी',
        admissionNo: 'ADM-2024-0107',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.absent,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal1_008',
        rollNo: '108',
        name: 'Salman Khurshid',
        nameUrdu: 'سلمان خورشید',
        nameHindi: 'सलमान खुर्शीद',
        admissionNo: 'ADM-2024-0108',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.leave,
        ],
        status: AttendanceStatus.present,
      ),
    ],
    'cls_aal_2': [
      const StudentAttendanceItem(
        studentId: 'std_aal2_001',
        rollNo: '201',
        name: 'Hamza Farooq',
        nameUrdu: 'حمزہ فاروق',
        nameHindi: 'हमज़ा फ़ारूक़',
        admissionNo: 'ADM-2023-0201',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal2_002',
        rollNo: '202',
        name: 'Rashid Minhas',
        nameUrdu: 'راشد منہاس',
        nameHindi: 'मुस्तफ़ा कमाल',
        admissionNo: 'ADM-2023-0202',
        lastThreeDays: [
          HistoryDayStatus.absent,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal2_003',
        rollNo: '203',
        name: 'Saad bin Abi Waqqas',
        nameUrdu: 'سعد بن ابی وقاص',
        nameHindi: 'अनस रिज़वान',
        admissionNo: 'ADM-2023-0203',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.leave,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_aal2_004',
        rollNo: '204',
        name: 'Khadija Tul Kubra',
        nameUrdu: 'خدیجہ الکبریٰ',
        nameHindi: 'फ़ातिमा ज़हरा',
        admissionNo: 'ADM-2023-0204',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.leave,
          HistoryDayStatus.leave,
        ],
        status: AttendanceStatus.present,
      ),
    ],
    'cls_sec_10': [
      const StudentAttendanceItem(
        studentId: 'std_sec10_001',
        rollNo: '301',
        name: 'Tariq Jameel Khan',
        nameUrdu: 'طارق جمیل خان',
        nameHindi: 'अहमद रज़ा',
        admissionNo: 'ADM-2024-0301',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_sec10_002',
        rollNo: '302',
        name: 'Salma Parveen',
        nameUrdu: 'سلمیٰ پروین',
        nameHindi: 'ज़ैनब बानो',
        admissionNo: 'ADM-2024-0302',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.absent,
          HistoryDayStatus.absent,
        ],
        status: AttendanceStatus.absent,
      ),
      const StudentAttendanceItem(
        studentId: 'std_sec10_003',
        rollNo: '303',
        name: 'Rehan Siddiqui',
        nameUrdu: 'ریحان صدیقی',
        nameHindi: 'साद मंसूर',
        admissionNo: 'ADM-2024-0303',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_sec10_004',
        rollNo: '304',
        name: 'Yasmin Bano',
        nameUrdu: 'یاسمین بانو',
        nameHindi: 'मरियम सिद्दीक़ी',
        admissionNo: 'ADM-2024-0304',
        lastThreeDays: [
          HistoryDayStatus.leave,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
    ],
    'cls_sec_9': [
      const StudentAttendanceItem(
        studentId: 'std_sec9_001',
        rollNo: '401',
        name: 'Arshad Warsi',
        nameUrdu: 'ارشد وارثی',
        nameHindi: 'हसन अली',
        admissionNo: 'ADM-2025-0401',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_sec9_002',
        rollNo: '402',
        name: 'Nadia Jamil',
        nameUrdu: 'نادیہ جمیل',
        nameHindi: 'ख़दीजा तुल कुबरा',
        admissionNo: 'ADM-2025-0402',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.absent,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
    ],
    'cls_hfz_1': [
      const StudentAttendanceItem(
        studentId: 'std_hfz1_001',
        rollNo: '501',
        name: 'Hafiz Umair Siddiqui',
        nameUrdu: 'حافظ عمیر صدیقی',
        nameHindi: 'हाफ़िज़ अबू बक्र',
        admissionNo: 'ADM-2024-0501',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_hfz1_002',
        rollNo: '502',
        name: 'Hafiz Anas Deobandi',
        nameUrdu: 'حافظ انس دیوبندی',
        nameHindi: 'हाफ़िज़ यह्या नोमानी',
        admissionNo: 'ADM-2024-0502',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.leave,
        ],
        status: AttendanceStatus.present,
      ),
    ],
    'cls_faz_1': [
      const StudentAttendanceItem(
        studentId: 'std_faz1_001',
        rollNo: '601',
        name: 'Mawlana Talha Usmani',
        nameUrdu: 'مولانا طلحہ عثمانی',
        nameHindi: 'मौलाना तल्हा उस्मानी',
        admissionNo: 'ADM-2022-0601',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
      const StudentAttendanceItem(
        studentId: 'std_faz1_002',
        rollNo: '602',
        name: 'Mawlana Huzaifa Qasmi',
        nameUrdu: 'مولانا حذیفہ قاسمی',
        nameHindi: 'मौलाना हुज़ैफ़ा क़ासिमी',
        admissionNo: 'ADM-2022-0602',
        lastThreeDays: [
          HistoryDayStatus.present,
          HistoryDayStatus.present,
          HistoryDayStatus.present,
        ],
        status: AttendanceStatus.present,
      ),
    ],
  };

  static List<ClassEntity> getClassesForCourse(String courseId) {
    return classes.where((c) => c.courseId == courseId).toList();
  }

  static List<StudentAttendanceItem> getStudentRoster(String classId) {
    final list = _rosters[classId] ?? _rosters['cls_aal_1']!;
    return list.map((item) => item.copyWith()).toList();
  }

  static Future<bool> submitAttendanceBatch({
    required String classId,
    required List<StudentAttendanceItem> students,
  }) async {
    // Financial idempotency simulation & server write latency
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _rosters[classId] = students.map((s) => s.copyWith()).toList();
    return true;
  }
}
