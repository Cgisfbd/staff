import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';
import 'package:staff_app/features/salary_counter/domain/usecases/salary_counter_usecases.dart';
import 'package:staff_app/features/salary_counter/presentation/bloc/salary_counter_event.dart';
import 'package:staff_app/features/salary_counter/presentation/bloc/salary_counter_state.dart';

class SalaryCounterBloc extends Bloc<SalaryCounterEvent, SalaryCounterState> {
  final GetInstitutionalSalaryStatsUseCase getInstitutionalSalaryStatsUseCase;
  final GetFacultySalaryListUseCase getFacultySalaryListUseCase;
  final GetPaymentHistoryForFacultyUseCase getPaymentHistoryForFacultyUseCase;
  final DisburseSalaryUseCase disburseSalaryUseCase;

  SalaryCounterBloc({
    required this.getInstitutionalSalaryStatsUseCase,
    required this.getFacultySalaryListUseCase,
    required this.getPaymentHistoryForFacultyUseCase,
    required this.disburseSalaryUseCase,
  }) : super(SalaryCounterState(
          paymentDate: DateTime.now().toIso8601String().split('T')[0],
        )) {
    on<LoadSalaryInitialEvent>(_onLoadInitial);
    on<SearchFacultyEvent>(_onSearchFaculty);
    on<FilterResidenceEvent>(_onFilterResidence);
    on<SelectTeacherEvent>(_onSelectTeacher);
    on<DeselectTeacherEvent>(_onDeselectTeacher);
    on<ToggleSalaryMonthEvent>(_onToggleSalaryMonth);
    on<SelectAllDueMonthsEvent>(_onSelectAllDueMonths);
    on<ResetSalaryMonthSelectionEvent>(_onResetSalaryMonthSelection);
    on<SetDeductionEvent>(_onSetDeduction);
    on<RemoveDeductionEvent>(_onRemoveDeduction);
    on<UpdatePaymentModeEvent>(_onUpdatePaymentMode);
    on<UpdatePaymentDateEvent>(_onUpdatePaymentDate);
    on<UpdateTransactionRefEvent>(_onUpdateTransactionRef);
    on<ExecuteSalaryDisbursementEvent>(_onExecuteSalaryDisbursement);
    on<DismissSalaryVoucherEvent>(_onDismissSalaryVoucher);
  }

  Future<void> _onLoadInitial(
    LoadSalaryInitialEvent event,
    Emitter<SalaryCounterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final statsRes = await getInstitutionalSalaryStatsUseCase();
    final facultyRes = await getFacultySalaryListUseCase();

    statsRes.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (stats) {
        facultyRes.fold(
          (failure) => emit(state.copyWith(isLoading: false, stats: stats, errorMessage: failure.message)),
          (faculty) => emit(state.copyWith(
            isLoading: false,
            stats: stats,
            facultyList: faculty,
            isDetailMode: false,
          )),
        );
      },
    );
  }

  void _onSearchFaculty(
    SearchFacultyEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterResidence(
    FilterResidenceEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(residenceFilter: event.filter));
  }

  Future<void> _onSelectTeacher(
    SelectTeacherEvent event,
    Emitter<SalaryCounterState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      selectedTeacher: event.teacher,
      selectedMonths: const [],
      deductionsMap: const {},
      isDetailMode: true,
      errorMessage: null,
    ));

    final historyRes = await getPaymentHistoryForFacultyUseCase(event.teacher.id);
    historyRes.fold(
      (failure) => emit(state.copyWith(isLoading: false)),
      (history) => emit(state.copyWith(
        isLoading: false,
        teacherReceipts: history,
      )),
    );
  }

  void _onDeselectTeacher(
    DeselectTeacherEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(
      isDetailMode: false,
      clearSelectedTeacher: true,
      selectedMonths: const [],
      deductionsMap: const {},
    ));
  }

  void _onToggleSalaryMonth(
    ToggleSalaryMonthEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    if (state.paidMonthsSet.contains(event.month)) return;

    final list = List<String>.from(state.selectedMonths);
    final map = Map<String, SalaryDeductionEntity>.from(state.deductionsMap);

    if (list.contains(event.month)) {
      list.remove(event.month);
      map.remove(event.month);
    } else {
      list.add(event.month);
    }

    emit(state.copyWith(selectedMonths: list, deductionsMap: map));
  }

  void _onSelectAllDueMonths(
    SelectAllDueMonthsEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    const currentPassedMonthIdx = 4; // August
    final dueMonths = kAcademicMonths
        .sublist(0, currentPassedMonthIdx + 1)
        .where((m) => !state.paidMonthsSet.contains(m))
        .toList();

    emit(state.copyWith(selectedMonths: dueMonths));
  }

  void _onResetSalaryMonthSelection(
    ResetSalaryMonthSelectionEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(selectedMonths: const [], deductionsMap: const {}));
  }

  void _onSetDeduction(
    SetDeductionEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    final map = Map<String, SalaryDeductionEntity>.from(state.deductionsMap);
    map[event.month] = SalaryDeductionEntity(
      month: event.month,
      amount: event.amount,
      reason: event.reason,
    );
    emit(state.copyWith(deductionsMap: map));
  }

  void _onRemoveDeduction(
    RemoveDeductionEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    final map = Map<String, SalaryDeductionEntity>.from(state.deductionsMap);
    map.remove(event.month);
    emit(state.copyWith(deductionsMap: map));
  }

  void _onUpdatePaymentMode(
    UpdatePaymentModeEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(paymentMode: event.mode));
  }

  void _onUpdatePaymentDate(
    UpdatePaymentDateEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(paymentDate: event.date));
  }

  void _onUpdateTransactionRef(
    UpdateTransactionRefEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(transactionRef: event.ref));
  }

  Future<void> _onExecuteSalaryDisbursement(
    ExecuteSalaryDisbursementEvent event,
    Emitter<SalaryCounterState> emit,
  ) async {
    final teacher = state.selectedTeacher;
    if (teacher == null || state.selectedMonths.isEmpty) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final deductionsList = state.selectedMonths
        .where((m) => state.deductionsMap.containsKey(m))
        .map((m) => state.deductionsMap[m]!)
        .toList();

    final res = await disburseSalaryUseCase(
      teacherId: teacher.id,
      academicYear: '2026-2027',
      months: state.selectedMonths,
      amountPerMonth: teacher.monthlySalary,
      deductions: deductionsList,
      totalAmount: state.currentNetPayable,
      paymentDate: state.paymentDate,
      paymentMode: state.paymentMode,
      transactionRef: state.transactionRef.isNotEmpty ? state.transactionRef : null,
    );

    res.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      (newReceipt) {
        final updatedReceipts = [newReceipt, ...state.teacherReceipts];
        emit(state.copyWith(
          isSubmitting: false,
          teacherReceipts: updatedReceipts,
          generatedReceipt: newReceipt,
          selectedMonths: const [],
          deductionsMap: const {},
          successMessage: 'Salary disbursed successfully for ${newReceipt.months.join(", ")}! Ref: ${newReceipt.receiptNo}',
        ));
      },
    );
  }

  void _onDismissSalaryVoucher(
    DismissSalaryVoucherEvent event,
    Emitter<SalaryCounterState> emit,
  ) {
    emit(state.copyWith(clearGeneratedReceipt: true));
  }
}
