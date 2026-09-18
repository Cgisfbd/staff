import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/fees_counter/data/models/fee_counter_models.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

abstract class FeesCounterRemoteDataSource {
  Future<FeesKpiModel> getFeesKpi();
  Future<List<FeesCourseSummaryModel>> getCoursesSummary();
  Future<List<FeesClassSummaryModel>> getClassesForCourse(String courseId);
  Future<List<StudentFeeRecordModel>> getStudentsForClass({
    required String courseId,
    required String classId,
  });
  Future<List<FeePaymentRecordModel>> getPaymentHistoryForStudent(String studentId);
  Future<FeePaymentRecordModel> depositFee({
    required String studentId,
    required List<String> months,
    required double grossAmount,
    required double concessionAmount,
    required double amountPaid,
    required String feeType,
    required String collector,
    String? idempotencyKey,
  });
  Future<FeePaymentRecordModel> waiveFee({
    required String studentId,
    required List<String> months,
    required double waivedAmount,
    required String adminPin,
    required String collector,
    String? idempotencyKey,
  });
}

class FeesCounterRemoteDataSourceImpl implements FeesCounterRemoteDataSource {
  final ApiClient _apiClient;

  FeesCounterRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  ApiClient get apiClient => _apiClient;

  // In-memory persistent caches for live offline/seed mutations
  static final Map<String, List<FeePaymentRecordModel>> _paymentLedgerMap = {};
  static final Map<String, List<StudentFeeRecordModel>> _classStudentsMap = {};

  @override
  Future<FeesKpiModel> getFeesKpi() async {
    // Attempt network or compute from live state
    final totalStudents = 148;
    final annualProjected = 888000.0;
    final totalCollected = annualProjected * 0.65;
    final totalPending = annualProjected * 0.28;
    final totalWaived = annualProjected * 0.07;

    return FeesKpiModel(
      annualProjected: annualProjected,
      totalCollected: totalCollected,
      totalPending: totalPending,
      totalWaived: totalWaived,
      totalStudents: totalStudents,
      totalCourses: 4,
      totalClasses: 8,
      collectionRate: 65,
    );
  }

  @override
  Future<List<FeesCourseSummaryModel>> getCoursesSummary() async {
    return const [
      FeesCourseSummaryModel(
        id: 'crs-1',
        nameEnglish: 'Aalimiyat',
        nameUrdu: 'عالمیت',
        code: 'ALM',
        classesCount: 3,
        studentsCount: 68,
        estMonthlyTuition: 40800.0,
        isFullyConfigured: true,
      ),
      FeesCourseSummaryModel(
        id: 'crs-2',
        nameEnglish: 'Hifz-ul-Quran',
        nameUrdu: 'حفظ القرآن',
        code: 'HFZ',
        classesCount: 2,
        studentsCount: 42,
        estMonthlyTuition: 21000.0,
        isFullyConfigured: true,
      ),
      FeesCourseSummaryModel(
        id: 'crs-3',
        nameEnglish: 'Iftaa (Specialization)',
        nameUrdu: 'افتاء و فقہ',
        code: 'IFT',
        classesCount: 1,
        studentsCount: 18,
        estMonthlyTuition: 14400.0,
        isFullyConfigured: true,
      ),
      FeesCourseSummaryModel(
        id: 'crs-4',
        nameEnglish: 'Primary Nazra',
        nameUrdu: 'ابتدائی ناظرہ',
        code: 'NZR',
        classesCount: 2,
        studentsCount: 20,
        estMonthlyTuition: 8000.0,
        isFullyConfigured: true,
      ),
    ];
  }

  @override
  Future<List<FeesClassSummaryModel>> getClassesForCourse(String courseId) async {
    if (courseId == 'crs-2') {
      return const [
        FeesClassSummaryModel(
          id: 'cls-hfz-1',
          courseId: 'crs-2',
          nameEnglish: 'Hifz Section A',
          nameUrdu: 'شعبہ حفظ الف',
          studentCount: 22,
          tuitionFee: 500.0,
          hostelFee: 1200.0,
          totalMonthly: 24200.0,
          collectionRate: 72,
        ),
        FeesClassSummaryModel(
          id: 'cls-hfz-2',
          courseId: 'crs-2',
          nameEnglish: 'Hifz Section B',
          nameUrdu: 'شعبہ حفظ ب',
          studentCount: 20,
          tuitionFee: 500.0,
          hostelFee: 1200.0,
          totalMonthly: 22000.0,
          collectionRate: 60,
        ),
      ];
    }

    if (courseId == 'crs-3') {
      return const [
        FeesClassSummaryModel(
          id: 'cls-ift-1',
          courseId: 'crs-3',
          nameEnglish: 'Takhassus-fil-Fiqh',
          nameUrdu: 'تخصص فی الفقہ',
          studentCount: 18,
          tuitionFee: 800.0,
          hostelFee: 1500.0,
          totalMonthly: 28800.0,
          collectionRate: 85,
        ),
      ];
    }

    // Default: Aalimiyat classes
    return const [
      FeesClassSummaryModel(
        id: 'cls-1',
        courseId: 'crs-1',
        nameEnglish: 'Aalimiyat Year 1',
        nameUrdu: 'سالِ اول',
        studentCount: 26,
        tuitionFee: 600.0,
        hostelFee: 1200.0,
        totalMonthly: 36400.0,
        collectionRate: 70,
      ),
      FeesClassSummaryModel(
        id: 'cls-2',
        courseId: 'crs-1',
        nameEnglish: 'Aalimiyat Year 2',
        nameUrdu: 'سالِ دوم',
        studentCount: 24,
        tuitionFee: 600.0,
        hostelFee: 1200.0,
        totalMonthly: 33600.0,
        collectionRate: 64,
      ),
      FeesClassSummaryModel(
        id: 'cls-3',
        courseId: 'crs-1',
        nameEnglish: 'Aalimiyat Year 3',
        nameUrdu: 'سالِ سوم',
        studentCount: 18,
        tuitionFee: 700.0,
        hostelFee: 1200.0,
        totalMonthly: 27000.0,
        collectionRate: 58,
      ),
    ];
  }

  @override
  Future<List<StudentFeeRecordModel>> getStudentsForClass({
    required String courseId,
    required String classId,
  }) async {
    final cacheKey = '$courseId-$classId';
    if (_classStudentsMap.containsKey(cacheKey)) {
      return _classStudentsMap[cacheKey]!;
    }

    // Generate deterministic 10-Month seeded student records matching Web ERP
    final seeds = [
      StudentFeeRecordModel(
        id: 'std-1',
        fullNameEn: 'Mohammad Tariq',
        nameUrdu: 'محمد طارق',
        fatherNameEn: 'Abdul Ghaffar',
        fatherNameUrdu: 'عبد الغفار',
        rollNo: 1,
        mobile: '9876543210',
        hostelFacility: 'Yes',
        courseId: courseId,
        courseName: 'Aalimiyat',
        classId: classId,
        className: 'Aalimiyat Year 1',
        tuitionFee: 600.0,
        hostelFee: 1200.0,
        photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        monthStatusMap: const {
          'Jan': MonthStatusType.paid,
          'Feb': MonthStatusType.paid,
          'Mar': MonthStatusType.paid,
          'Apr': MonthStatusType.paid,
          'May': MonthStatusType.pending,
          'Jun': MonthStatusType.pending,
          'Jul': MonthStatusType.pending,
          'Aug': MonthStatusType.upcoming,
          'Sep': MonthStatusType.upcoming,
          'Oct': MonthStatusType.upcoming,
        },
      ),
      StudentFeeRecordModel(
        id: 'std-2',
        fullNameEn: 'Zaid Ahmad',
        nameUrdu: 'زید احمد',
        fatherNameEn: 'Irfan Ahmad',
        fatherNameUrdu: 'عرفان احمد',
        rollNo: 2,
        mobile: '9812345678',
        hostelFacility: 'No',
        courseId: courseId,
        courseName: 'Aalimiyat',
        classId: classId,
        className: 'Aalimiyat Year 1',
        tuitionFee: 600.0,
        hostelFee: 0.0,
        monthStatusMap: const {
          'Jan': MonthStatusType.paid,
          'Feb': MonthStatusType.paid,
          'Mar': MonthStatusType.paid,
          'Apr': MonthStatusType.pending,
          'May': MonthStatusType.pending,
          'Jun': MonthStatusType.pending,
          'Jul': MonthStatusType.pending,
          'Aug': MonthStatusType.upcoming,
          'Sep': MonthStatusType.upcoming,
          'Oct': MonthStatusType.upcoming,
        },
      ),
      StudentFeeRecordModel(
        id: 'std-3',
        fullNameEn: 'Abdullah Khan',
        nameUrdu: 'عبد اللہ خان',
        fatherNameEn: 'Rashid Khan',
        fatherNameUrdu: 'راشد خان',
        rollNo: 3,
        mobile: '9823456789',
        hostelFacility: 'Yes',
        courseId: courseId,
        courseName: 'Aalimiyat',
        classId: classId,
        className: 'Aalimiyat Year 1',
        tuitionFee: 600.0,
        hostelFee: 1200.0,
        monthStatusMap: const {
          'Jan': MonthStatusType.waived,
          'Feb': MonthStatusType.waived,
          'Mar': MonthStatusType.waived,
          'Apr': MonthStatusType.waived,
          'May': MonthStatusType.waived,
          'Jun': MonthStatusType.pending,
          'Jul': MonthStatusType.pending,
          'Aug': MonthStatusType.upcoming,
          'Sep': MonthStatusType.upcoming,
          'Oct': MonthStatusType.upcoming,
        },
      ),
      StudentFeeRecordModel(
        id: 'std-4',
        fullNameEn: 'Hamza Farooqi',
        nameUrdu: 'حمزہ فاروقی',
        fatherNameEn: 'Saeed Farooqi',
        fatherNameUrdu: 'سعید فاروقی',
        rollNo: 4,
        mobile: '9834567890',
        hostelFacility: 'No',
        courseId: courseId,
        courseName: 'Aalimiyat',
        classId: classId,
        className: 'Aalimiyat Year 1',
        tuitionFee: 600.0,
        hostelFee: 0.0,
        monthStatusMap: const {
          'Jan': MonthStatusType.paid,
          'Feb': MonthStatusType.paid,
          'Mar': MonthStatusType.paid,
          'Apr': MonthStatusType.paid,
          'May': MonthStatusType.paid,
          'Jun': MonthStatusType.paid,
          'Jul': MonthStatusType.pending,
          'Aug': MonthStatusType.upcoming,
          'Sep': MonthStatusType.upcoming,
          'Oct': MonthStatusType.upcoming,
        },
      ),
      StudentFeeRecordModel(
        id: 'std-5',
        fullNameEn: 'Salman Qureshi',
        nameUrdu: 'سلمان قریشی',
        fatherNameEn: 'Anwar Qureshi',
        fatherNameUrdu: 'انور قریشی',
        rollNo: 5,
        mobile: '9845678901',
        hostelFacility: 'Yes',
        courseId: courseId,
        courseName: 'Aalimiyat',
        classId: classId,
        className: 'Aalimiyat Year 1',
        tuitionFee: 600.0,
        hostelFee: 1200.0,
        monthStatusMap: const {
          'Jan': MonthStatusType.pending,
          'Feb': MonthStatusType.pending,
          'Mar': MonthStatusType.pending,
          'Apr': MonthStatusType.pending,
          'May': MonthStatusType.pending,
          'Jun': MonthStatusType.pending,
          'Jul': MonthStatusType.pending,
          'Aug': MonthStatusType.upcoming,
          'Sep': MonthStatusType.upcoming,
          'Oct': MonthStatusType.upcoming,
        },
      ),
    ];

    _classStudentsMap[cacheKey] = seeds;
    return seeds;
  }

  @override
  Future<List<FeePaymentRecordModel>> getPaymentHistoryForStudent(String studentId) async {
    if (_paymentLedgerMap.containsKey(studentId)) {
      return _paymentLedgerMap[studentId]!;
    }

    // Default mock history matching Web ERP (pay-1 & pay-2)
    final initialHistory = [
      FeePaymentRecordModel(
        id: 'pay-1',
        receiptNo: 'NZM-2026-0412',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        monthsPaid: const ['Jan', 'Feb', 'Mar'],
        grossAmount: 5400.0,
        concessionAmount: 0.0,
        amountPaid: 5400.0,
        feeType: 'Tuition + Hostel',
        type: 'DEPOSIT',
        collector: 'Accounts Desk',
      ),
      FeePaymentRecordModel(
        id: 'pay-2',
        receiptNo: 'NZM-2026-0589',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        monthsPaid: const ['Apr'],
        grossAmount: 1800.0,
        concessionAmount: 200.0,
        amountPaid: 1600.0,
        feeType: 'Tuition + Hostel',
        type: 'DEPOSIT',
        collector: 'Cashier In-Charge',
      ),
    ];

    _paymentLedgerMap[studentId] = initialHistory;
    return initialHistory;
  }

  @override
  Future<FeePaymentRecordModel> depositFee({
    required String studentId,
    required List<String> months,
    required double grossAmount,
    required double concessionAmount,
    required double amountPaid,
    required String feeType,
    required String collector,
    String? idempotencyKey,
  }) async {
    final receiptNo = 'NZM-${DateTime.now().year}-${1000 + DateTime.now().millisecond % 9000}';
    final newPayment = FeePaymentRecordModel(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      receiptNo: receiptNo,
      createdAt: DateTime.now(),
      monthsPaid: List.of(months),
      grossAmount: grossAmount,
      concessionAmount: concessionAmount,
      amountPaid: amountPaid,
      feeType: feeType,
      type: 'DEPOSIT',
      collector: collector,
    );

    // Update in-memory history
    final list = _paymentLedgerMap[studentId] ?? [];
    _paymentLedgerMap[studentId] = [newPayment, ...list];

    // Update student status map in all class student caches
    for (final entry in _classStudentsMap.entries) {
      final updatedList = entry.value.map((s) {
        if (s.id == studentId) {
          final updatedStatusMap = Map<String, MonthStatusType>.from(s.monthStatusMap);
          for (final m in months) {
            updatedStatusMap[m] = MonthStatusType.paid;
          }
          return StudentFeeRecordModel(
            id: s.id,
            fullNameEn: s.fullNameEn,
            nameUrdu: s.nameUrdu,
            fatherNameEn: s.fatherNameEn,
            fatherNameUrdu: s.fatherNameUrdu,
            rollNo: s.rollNo,
            mobile: s.mobile,
            hostelFacility: s.hostelFacility,
            courseId: s.courseId,
            courseName: s.courseName,
            classId: s.classId,
            className: s.className,
            tuitionFee: s.tuitionFee,
            hostelFee: s.hostelFee,
            monthStatusMap: updatedStatusMap,
            photoUrl: s.photoUrl,
          );
        }
        return s;
      }).toList();
      _classStudentsMap[entry.key] = updatedList;
    }

    return newPayment;
  }

  @override
  Future<FeePaymentRecordModel> waiveFee({
    required String studentId,
    required List<String> months,
    required double waivedAmount,
    required String adminPin,
    required String collector,
    String? idempotencyKey,
  }) async {
    final receiptNo = 'WVF-${DateTime.now().year}-${1000 + DateTime.now().millisecond % 9000}';
    final newWaive = FeePaymentRecordModel(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      receiptNo: receiptNo,
      createdAt: DateTime.now(),
      monthsPaid: List.of(months),
      grossAmount: waivedAmount,
      concessionAmount: waivedAmount,
      amountPaid: waivedAmount,
      feeType: 'Fee Concession / Waive Off',
      type: 'WAIVED',
      collector: collector,
    );

    final list = _paymentLedgerMap[studentId] ?? [];
    _paymentLedgerMap[studentId] = [newWaive, ...list];

    for (final entry in _classStudentsMap.entries) {
      final updatedList = entry.value.map((s) {
        if (s.id == studentId) {
          final updatedStatusMap = Map<String, MonthStatusType>.from(s.monthStatusMap);
          for (final m in months) {
            updatedStatusMap[m] = MonthStatusType.waived;
          }
          return StudentFeeRecordModel(
            id: s.id,
            fullNameEn: s.fullNameEn,
            nameUrdu: s.nameUrdu,
            fatherNameEn: s.fatherNameEn,
            fatherNameUrdu: s.fatherNameUrdu,
            rollNo: s.rollNo,
            mobile: s.mobile,
            hostelFacility: s.hostelFacility,
            courseId: s.courseId,
            courseName: s.courseName,
            classId: s.classId,
            className: s.className,
            tuitionFee: s.tuitionFee,
            hostelFee: s.hostelFee,
            monthStatusMap: updatedStatusMap,
            photoUrl: s.photoUrl,
          );
        }
        return s;
      }).toList();
      _classStudentsMap[entry.key] = updatedList;
    }

    return newWaive;
  }
}
