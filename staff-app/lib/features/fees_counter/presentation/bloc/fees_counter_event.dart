import 'package:equatable/equatable.dart';
import 'package:staff_app/features/fees_counter/domain/entities/fee_counter_entities.dart';

abstract class FeesCounterEvent extends Equatable {
  const FeesCounterEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeesInitialEvent extends FeesCounterEvent {
  const LoadFeesInitialEvent();
}

class SearchQueryChangedEvent extends FeesCounterEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectCourseEvent extends FeesCounterEvent {
  final FeesCourseSummaryEntity course;
  const SelectCourseEvent(this.course);

  @override
  List<Object?> get props => [course];
}

class SelectClassEvent extends FeesCounterEvent {
  final FeesClassSummaryEntity cls;
  const SelectClassEvent(this.cls);

  @override
  List<Object?> get props => [cls];
}

class SelectStudentEvent extends FeesCounterEvent {
  final StudentFeeRecordEntity student;
  const SelectStudentEvent(this.student);

  @override
  List<Object?> get props => [student];
}

class NavigateBackLevelEvent extends FeesCounterEvent {
  const NavigateBackLevelEvent();
}

class ToggleMonthSelectionEvent extends FeesCounterEvent {
  final String monthShort;
  const ToggleMonthSelectionEvent(this.monthShort);

  @override
  List<Object?> get props => [monthShort];
}

class SelectAllPendingMonthsEvent extends FeesCounterEvent {
  const SelectAllPendingMonthsEvent();
}

class SelectNextPendingMonthEvent extends FeesCounterEvent {
  const SelectNextPendingMonthEvent();
}

class ClearMonthSelectionEvent extends FeesCounterEvent {
  const ClearMonthSelectionEvent();
}

class SetConcessionAmountEvent extends FeesCounterEvent {
  final double amount;
  const SetConcessionAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ApplyPercentConcessionEvent extends FeesCounterEvent {
  final int percent;
  const ApplyPercentConcessionEvent(this.percent);

  @override
  List<Object?> get props => [percent];
}

class ConfirmDepositEvent extends FeesCounterEvent {
  const ConfirmDepositEvent();
}

class ConfirmWaiveOffEvent extends FeesCounterEvent {
  final String adminPin;
  const ConfirmWaiveOffEvent(this.adminPin);

  @override
  List<Object?> get props => [adminPin];
}

class DismissReceiptVoucherEvent extends FeesCounterEvent {
  const DismissReceiptVoucherEvent();
}
