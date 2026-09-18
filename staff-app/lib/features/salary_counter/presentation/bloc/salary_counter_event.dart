import 'package:equatable/equatable.dart';
import 'package:staff_app/features/salary_counter/domain/entities/salary_counter_entities.dart';

abstract class SalaryCounterEvent extends Equatable {
  const SalaryCounterEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalaryInitialEvent extends SalaryCounterEvent {
  const LoadSalaryInitialEvent();
}

class SelectTeacherEvent extends SalaryCounterEvent {
  final FacultySalaryRecordEntity teacher;
  const SelectTeacherEvent(this.teacher);

  @override
  List<Object?> get props => [teacher];
}

class DeselectTeacherEvent extends SalaryCounterEvent {
  const DeselectTeacherEvent();
}

class SearchFacultyEvent extends SalaryCounterEvent {
  final String query;
  const SearchFacultyEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterResidenceEvent extends SalaryCounterEvent {
  final String filter; // 'ALL' | 'DUE' | 'HOSTEL' | 'DAY_SCHOLAR'
  const FilterResidenceEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ToggleSalaryMonthEvent extends SalaryCounterEvent {
  final String month;
  const ToggleSalaryMonthEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class SelectAllDueMonthsEvent extends SalaryCounterEvent {
  const SelectAllDueMonthsEvent();
}

class ResetSalaryMonthSelectionEvent extends SalaryCounterEvent {
  const ResetSalaryMonthSelectionEvent();
}

class SetDeductionEvent extends SalaryCounterEvent {
  final String month;
  final double amount;
  final String reason;

  const SetDeductionEvent({
    required this.month,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object?> get props => [month, amount, reason];
}

class RemoveDeductionEvent extends SalaryCounterEvent {
  final String month;
  const RemoveDeductionEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class UpdatePaymentModeEvent extends SalaryCounterEvent {
  final String mode;
  const UpdatePaymentModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class UpdatePaymentDateEvent extends SalaryCounterEvent {
  final String date;
  const UpdatePaymentDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateTransactionRefEvent extends SalaryCounterEvent {
  final String ref;
  const UpdateTransactionRefEvent(this.ref);

  @override
  List<Object?> get props => [ref];
}

class ExecuteSalaryDisbursementEvent extends SalaryCounterEvent {
  const ExecuteSalaryDisbursementEvent();
}

class DismissSalaryVoucherEvent extends SalaryCounterEvent {
  const DismissSalaryVoucherEvent();
}
