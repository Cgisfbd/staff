import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';
import 'package:staff_app/features/fees_counter/domain/usecases/fees_counter_usecases.dart';
import 'package:staff_app/features/fees_counter/presentation/bloc/fees_counter_event.dart';
import 'package:staff_app/features/fees_counter/presentation/bloc/fees_counter_state.dart';

class FeesCounterBloc extends Bloc<FeesCounterEvent, FeesCounterState> {
  final GetFeesKpiUseCase getFeesKpiUseCase;
  final GetCoursesSummaryUseCase getCoursesSummaryUseCase;
  final GetClassesForCourseUseCase getClassesForCourseUseCase;
  final GetStudentsForClassUseCase getStudentsForClassUseCase;
  final GetPaymentHistoryForStudentUseCase getPaymentHistoryForStudentUseCase;
  final DepositFeeUseCase depositFeeUseCase;
  final WaiveFeeUseCase waiveFeeUseCase;

  FeesCounterBloc({
    required this.getFeesKpiUseCase,
    required this.getCoursesSummaryUseCase,
    required this.getClassesForCourseUseCase,
    required this.getStudentsForClassUseCase,
    required this.getPaymentHistoryForStudentUseCase,
    required this.depositFeeUseCase,
    required this.waiveFeeUseCase,
  }) : super(const FeesCounterState()) {
    on<LoadFeesInitialEvent>(_onLoadInitial);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<SelectCourseEvent>(_onSelectCourse);
    on<SelectClassEvent>(_onSelectClass);
    on<SelectStudentEvent>(_onSelectStudent);
    on<NavigateBackLevelEvent>(_onNavigateBackLevel);
    on<ToggleMonthSelectionEvent>(_onToggleMonthSelection);
    on<SelectAllPendingMonthsEvent>(_onSelectAllPendingMonths);
    on<SelectNextPendingMonthEvent>(_onSelectNextPendingMonth);
    on<ClearMonthSelectionEvent>(_onClearMonthSelection);
    on<SetConcessionAmountEvent>(_onSetConcessionAmount);
    on<ApplyPercentConcessionEvent>(_onApplyPercentConcession);
    on<ConfirmDepositEvent>(_onConfirmDeposit);
    on<ConfirmWaiveOffEvent>(_onConfirmWaiveOff);
    on<DismissReceiptVoucherEvent>(_onDismissReceiptVoucher);
  }

  Future<void> _onLoadInitial(
    LoadFeesInitialEvent event,
    Emitter<FeesCounterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final kpiRes = await getFeesKpiUseCase();
    final coursesRes = await getCoursesSummaryUseCase();

    kpiRes.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (kpi) {
        coursesRes.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            kpi: kpi,
            errorMessage: failure.message,
          )),
          (courses) => emit(state.copyWith(
            isLoading: false,
            kpi: kpi,
            courses: courses,
            currentLevel: FeesCounterLevel.courses,
          )),
        );
      },
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onSelectCourse(
    SelectCourseEvent event,
    Emitter<FeesCounterState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      selectedCourse: event.course,
      searchQuery: '',
      errorMessage: null,
    ));

    final res = await getClassesForCourseUseCase(event.course.id);
    res.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (classes) => emit(state.copyWith(
        isLoading: false,
        classes: classes,
        currentLevel: FeesCounterLevel.classes,
      )),
    );
  }

  Future<void> _onSelectClass(
    SelectClassEvent event,
    Emitter<FeesCounterState> emit,
  ) async {
    if (state.selectedCourse == null) return;
    emit(state.copyWith(
      isLoading: true,
      selectedClass: event.cls,
      searchQuery: '',
      errorMessage: null,
    ));

    final res = await getStudentsForClassUseCase(
      courseId: state.selectedCourse!.id,
      classId: event.cls.id,
    );
    res.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (students) => emit(state.copyWith(
        isLoading: false,
        students: students,
        currentLevel: FeesCounterLevel.students,
      )),
    );
  }

  Future<void> _onSelectStudent(
    SelectStudentEvent event,
    Emitter<FeesCounterState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      selectedStudent: event.student,
      selectedMonths: const [],
      concessionAmount: 0.0,
      errorMessage: null,
    ));

    final res = await getPaymentHistoryForStudentUseCase(event.student.id);
    res.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        currentLevel: FeesCounterLevel.studentProfile,
      )),
      (history) => emit(state.copyWith(
        isLoading: false,
        studentPaymentsHistory: history,
        currentLevel: FeesCounterLevel.studentProfile,
      )),
    );
  }

  void _onNavigateBackLevel(
    NavigateBackLevelEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    switch (state.currentLevel) {
      case FeesCounterLevel.studentProfile:
        emit(state.copyWith(
          currentLevel: FeesCounterLevel.students,
          clearSelectedStudent: true,
          selectedMonths: const [],
          concessionAmount: 0.0,
          searchQuery: '',
        ));
        break;
      case FeesCounterLevel.students:
        emit(state.copyWith(
          currentLevel: FeesCounterLevel.classes,
          clearSelectedClass: true,
          students: const [],
          searchQuery: '',
        ));
        break;
      case FeesCounterLevel.classes:
        emit(state.copyWith(
          currentLevel: FeesCounterLevel.courses,
          clearSelectedCourse: true,
          classes: const [],
          searchQuery: '',
        ));
        break;
      case FeesCounterLevel.courses:
        // Already at top level
        break;
    }
  }

  void _onToggleMonthSelection(
    ToggleMonthSelectionEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    final list = List<String>.from(state.selectedMonths);
    if (list.contains(event.monthShort)) {
      list.remove(event.monthShort);
    } else {
      list.add(event.monthShort);
    }
    emit(state.copyWith(selectedMonths: list));
  }

  void _onSelectAllPendingMonths(
    SelectAllPendingMonthsEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    if (state.selectedStudent == null) return;
    final pendingMonths = kCalendarMonths
        .where((m) =>
            state.selectedStudent!.monthStatusMap[m.shortEn] == MonthStatusType.pending)
        .map((m) => m.shortEn)
        .toList();

    emit(state.copyWith(selectedMonths: pendingMonths));
  }

  void _onSelectNextPendingMonth(
    SelectNextPendingMonthEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    if (state.selectedStudent == null) return;
    for (final m in kCalendarMonths) {
      if (state.selectedStudent!.monthStatusMap[m.shortEn] == MonthStatusType.pending &&
          !state.selectedMonths.contains(m.shortEn)) {
        final updated = List<String>.from(state.selectedMonths)..add(m.shortEn);
        emit(state.copyWith(selectedMonths: updated));
        return;
      }
    }
  }

  void _onClearMonthSelection(
    ClearMonthSelectionEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    emit(state.copyWith(selectedMonths: const [], concessionAmount: 0.0));
  }

  void _onSetConcessionAmount(
    SetConcessionAmountEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    emit(state.copyWith(concessionAmount: event.amount));
  }

  void _onApplyPercentConcession(
    ApplyPercentConcessionEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    final gross = state.currentGrossAmount;
    final concession = (gross * event.percent) / 100.0;
    emit(state.copyWith(concessionAmount: concession));
  }

  Future<void> _onConfirmDeposit(
    ConfirmDepositEvent event,
    Emitter<FeesCounterState> emit,
  ) async {
    final student = state.selectedStudent;
    if (student == null || state.selectedMonths.isEmpty) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final feeType = student.isHostel ? 'Tuition + Hostel' : 'Tuition Only';
    final res = await depositFeeUseCase(
      studentId: student.id,
      months: state.selectedMonths,
      grossAmount: state.currentGrossAmount,
      concessionAmount: state.concessionAmount,
      amountPaid: state.currentNetPayable,
      feeType: feeType,
      collector: 'Accounts Desk',
    );

    res.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      (newReceipt) {
        // Update local student status map
        final updatedMap = Map<String, MonthStatusType>.from(student.monthStatusMap);
        for (final m in state.selectedMonths) {
          updatedMap[m] = MonthStatusType.paid;
        }

        final updatedStudent = StudentFeeRecordEntity(
          id: student.id,
          fullNameEn: student.fullNameEn,
          nameUrdu: student.nameUrdu,
          fatherNameEn: student.fatherNameEn,
          fatherNameUrdu: student.fatherNameUrdu,
          rollNo: student.rollNo,
          mobile: student.mobile,
          hostelFacility: student.hostelFacility,
          courseId: student.courseId,
          courseName: student.courseName,
          classId: student.classId,
          className: student.className,
          tuitionFee: student.tuitionFee,
          hostelFee: student.hostelFee,
          monthStatusMap: updatedMap,
          photoUrl: student.photoUrl,
        );

        final updatedHistory = [newReceipt, ...state.studentPaymentsHistory];

        emit(state.copyWith(
          isSubmitting: false,
          selectedStudent: updatedStudent,
          studentPaymentsHistory: updatedHistory,
          generatedReceipt: newReceipt,
          selectedMonths: const [],
          concessionAmount: 0.0,
          successMessage: 'Fee deposited successfully! Receipt: ${newReceipt.receiptNo}',
        ));
      },
    );
  }

  Future<void> _onConfirmWaiveOff(
    ConfirmWaiveOffEvent event,
    Emitter<FeesCounterState> emit,
  ) async {
    final student = state.selectedStudent;
    if (student == null || state.selectedMonths.isEmpty) return;

    if (event.adminPin.trim().length < 4) {
      emit(state.copyWith(errorMessage: 'Invalid Admin PIN. Minimum 4 digits required.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final res = await waiveFeeUseCase(
      studentId: student.id,
      months: state.selectedMonths,
      waivedAmount: state.currentGrossAmount,
      adminPin: event.adminPin,
      collector: 'Authorized Admin / Mohtamim',
    );

    res.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      (newReceipt) {
        final updatedMap = Map<String, MonthStatusType>.from(student.monthStatusMap);
        for (final m in state.selectedMonths) {
          updatedMap[m] = MonthStatusType.waived;
        }

        final updatedStudent = StudentFeeRecordEntity(
          id: student.id,
          fullNameEn: student.fullNameEn,
          nameUrdu: student.nameUrdu,
          fatherNameEn: student.fatherNameEn,
          fatherNameUrdu: student.fatherNameUrdu,
          rollNo: student.rollNo,
          mobile: student.mobile,
          hostelFacility: student.hostelFacility,
          courseId: student.courseId,
          courseName: student.courseName,
          classId: student.classId,
          className: student.className,
          tuitionFee: student.tuitionFee,
          hostelFee: student.hostelFee,
          monthStatusMap: updatedMap,
          photoUrl: student.photoUrl,
        );

        final updatedHistory = [newReceipt, ...state.studentPaymentsHistory];

        emit(state.copyWith(
          isSubmitting: false,
          selectedStudent: updatedStudent,
          studentPaymentsHistory: updatedHistory,
          generatedReceipt: newReceipt,
          selectedMonths: const [],
          concessionAmount: 0.0,
          successMessage: 'Selected months waived off successfully! Ref: ${newReceipt.receiptNo}',
        ));
      },
    );
  }

  void _onDismissReceiptVoucher(
    DismissReceiptVoucherEvent event,
    Emitter<FeesCounterState> emit,
  ) {
    emit(state.copyWith(clearGeneratedReceipt: true));
  }
}
