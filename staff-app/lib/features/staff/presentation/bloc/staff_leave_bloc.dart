import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/staff/data/models/staff_leave_model.dart';
import 'package:staff_app/features/staff/data/repositories/staff_leave_repository_impl.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

// =============================================================================
// EVENTS
// =============================================================================
abstract class StaffLeaveEvent extends Equatable {
  const StaffLeaveEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffLeavesEvent extends StaffLeaveEvent {
  const LoadStaffLeavesEvent();
}

class RefreshStaffLeavesEvent extends StaffLeaveEvent {
  const RefreshStaffLeavesEvent();
}

class FilterStaffLeavesEvent extends StaffLeaveEvent {
  const FilterStaffLeavesEvent({this.status});
  final StaffLeaveStatus? status;

  @override
  List<Object?> get props => [status];
}

class SearchStaffLeavesEvent extends StaffLeaveEvent {
  const SearchStaffLeavesEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class ApproveStaffLeaveEvent extends StaffLeaveEvent {
  const ApproveStaffLeaveEvent(this.leaveId);
  final String leaveId;

  @override
  List<Object?> get props => [leaveId];
}

class RejectStaffLeaveEvent extends StaffLeaveEvent {
  const RejectStaffLeaveEvent({
    required this.leaveId,
    required this.rejectionReason,
  });
  final String leaveId;
  final String rejectionReason;

  @override
  List<Object?> get props => [leaveId, rejectionReason];
}

class ApplyStaffLeaveEvent extends StaffLeaveEvent {
  const ApplyStaffLeaveEvent(this.leave);
  final StaffLeaveModel leave;

  @override
  List<Object?> get props => [leave];
}

// =============================================================================
// STATES
// =============================================================================
abstract class StaffLeaveState extends Equatable {
  const StaffLeaveState();

  @override
  List<Object?> get props => [];
}

class StaffLeaveInitial extends StaffLeaveState {
  const StaffLeaveInitial();
}

class StaffLeaveLoading extends StaffLeaveState {
  const StaffLeaveLoading();
}

class StaffLeaveLoaded extends StaffLeaveState {
  const StaffLeaveLoaded({
    required this.allLeaves,
    required this.filteredLeaves,
    required this.stats,
    this.selectedStatus,
    this.searchQuery = '',
    this.isProcessingId,
    this.actionSuccessMessage,
  });

  final List<StaffLeaveEntity> allLeaves;
  final List<StaffLeaveEntity> filteredLeaves;
  final StaffLeaveStatsEntity stats;
  final StaffLeaveStatus? selectedStatus;
  final String searchQuery;
  final String? isProcessingId;
  final String? actionSuccessMessage;

  StaffLeaveLoaded copyWith({
    List<StaffLeaveEntity>? allLeaves,
    List<StaffLeaveEntity>? filteredLeaves,
    StaffLeaveStatsEntity? stats,
    StaffLeaveStatus? selectedStatus,
    bool clearStatusFilter = false,
    String? searchQuery,
    String? isProcessingId,
    bool clearProcessingId = false,
    String? actionSuccessMessage,
  }) {
    return StaffLeaveLoaded(
      allLeaves: allLeaves ?? this.allLeaves,
      filteredLeaves: filteredLeaves ?? this.filteredLeaves,
      stats: stats ?? this.stats,
      selectedStatus: clearStatusFilter ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      isProcessingId: clearProcessingId ? null : (isProcessingId ?? this.isProcessingId),
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        allLeaves,
        filteredLeaves,
        stats,
        selectedStatus,
        searchQuery,
        isProcessingId,
        actionSuccessMessage,
      ];
}

class StaffLeaveError extends StaffLeaveState {
  const StaffLeaveError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLOC
// =============================================================================
class StaffLeaveBloc extends Bloc<StaffLeaveEvent, StaffLeaveState> {
  StaffLeaveBloc({required StaffLeaveRepository repository})
      : _repository = repository,
        super(const StaffLeaveInitial()) {
    on<LoadStaffLeavesEvent>(_onLoadLeaves);
    on<RefreshStaffLeavesEvent>(_onRefreshLeaves);
    on<FilterStaffLeavesEvent>(_onFilterLeaves);
    on<SearchStaffLeavesEvent>(_onSearchLeaves);
    on<ApproveStaffLeaveEvent>(_onApproveLeave);
    on<RejectStaffLeaveEvent>(_onRejectLeave);
    on<ApplyStaffLeaveEvent>(_onApplyLeave);
  }

  final StaffLeaveRepository _repository;

  Future<void> _onLoadLeaves(
    LoadStaffLeavesEvent event,
    Emitter<StaffLeaveState> emit,
  ) async {
    emit(const StaffLeaveLoading());
    try {
      final leaves = await _repository.getStaffLeaves();
      final stats = await _repository.getStaffLeaveStats();
      emit(StaffLeaveLoaded(
        allLeaves: leaves,
        filteredLeaves: leaves,
        stats: stats,
      ));
    } catch (e) {
      emit(StaffLeaveError('Failed to load leave records: $e'));
    }
  }

  Future<void> _onRefreshLeaves(
    RefreshStaffLeavesEvent event,
    Emitter<StaffLeaveState> emit,
  ) async {
    try {
      final current = state;
      final selectedStatus = current is StaffLeaveLoaded ? current.selectedStatus : null;
      final query = current is StaffLeaveLoaded ? current.searchQuery : '';

      final leaves = await _repository.getStaffLeaves();
      final stats = await _repository.getStaffLeaveStats();
      final filtered = _applyFilters(leaves, selectedStatus, query);

      emit(StaffLeaveLoaded(
        allLeaves: leaves,
        filteredLeaves: filtered,
        stats: stats,
        selectedStatus: selectedStatus,
        searchQuery: query,
      ));
    } catch (e) {
      emit(StaffLeaveError('Failed to refresh leaves: $e'));
    }
  }

  void _onFilterLeaves(
    FilterStaffLeavesEvent event,
    Emitter<StaffLeaveState> emit,
  ) {
    final current = state;
    if (current is! StaffLeaveLoaded) return;

    final filtered = _applyFilters(current.allLeaves, event.status, current.searchQuery);
    emit(current.copyWith(
      selectedStatus: event.status,
      clearStatusFilter: event.status == null,
      filteredLeaves: filtered,
    ));
  }

  void _onSearchLeaves(
    SearchStaffLeavesEvent event,
    Emitter<StaffLeaveState> emit,
  ) {
    final current = state;
    if (current is! StaffLeaveLoaded) return;

    final filtered = _applyFilters(current.allLeaves, current.selectedStatus, event.query);
    emit(current.copyWith(
      searchQuery: event.query,
      filteredLeaves: filtered,
    ));
  }

  Future<void> _onApproveLeave(
    ApproveStaffLeaveEvent event,
    Emitter<StaffLeaveState> emit,
  ) async {
    final current = state;
    if (current is! StaffLeaveLoaded) return;

    emit(current.copyWith(isProcessingId: event.leaveId));
    try {
      final updated = await _repository.updateLeaveStatus(
        leaveId: event.leaveId,
        status: StaffLeaveStatus.approved,
      );

      final updatedAll = current.allLeaves.map((l) => l.id == event.leaveId ? updated : l).toList();
      final stats = await _repository.getStaffLeaveStats();
      final filtered = _applyFilters(updatedAll, current.selectedStatus, current.searchQuery);

      emit(current.copyWith(
        allLeaves: updatedAll,
        filteredLeaves: filtered,
        stats: stats,
        clearProcessingId: true,
        actionSuccessMessage: 'Leave request for ${updated.teacherName} approved!',
      ));
    } catch (e) {
      emit(current.copyWith(
        clearProcessingId: true,
        actionSuccessMessage: 'Failed to approve leave: $e',
      ));
    }
  }

  Future<void> _onRejectLeave(
    RejectStaffLeaveEvent event,
    Emitter<StaffLeaveState> emit,
  ) async {
    final current = state;
    if (current is! StaffLeaveLoaded) return;

    emit(current.copyWith(isProcessingId: event.leaveId));
    try {
      final updated = await _repository.updateLeaveStatus(
        leaveId: event.leaveId,
        status: StaffLeaveStatus.rejected,
        rejectionReason: event.rejectionReason,
      );

      final updatedAll = current.allLeaves.map((l) => l.id == event.leaveId ? updated : l).toList();
      final stats = await _repository.getStaffLeaveStats();
      final filtered = _applyFilters(updatedAll, current.selectedStatus, current.searchQuery);

      emit(current.copyWith(
        allLeaves: updatedAll,
        filteredLeaves: filtered,
        stats: stats,
        clearProcessingId: true,
        actionSuccessMessage: 'Leave request for ${updated.teacherName} rejected.',
      ));
    } catch (e) {
      emit(current.copyWith(
        clearProcessingId: true,
        actionSuccessMessage: 'Failed to reject leave: $e',
      ));
    }
  }

  Future<void> _onApplyLeave(
    ApplyStaffLeaveEvent event,
    Emitter<StaffLeaveState> emit,
  ) async {
    final current = state;
    if (current is! StaffLeaveLoaded) return;

    try {
      final created = await _repository.applyStaffLeave(leave: event.leave);
      final updatedAll = [created, ...current.allLeaves];
      final stats = await _repository.getStaffLeaveStats();
      final filtered = _applyFilters(updatedAll, current.selectedStatus, current.searchQuery);

      emit(current.copyWith(
        allLeaves: updatedAll,
        filteredLeaves: filtered,
        stats: stats,
        actionSuccessMessage: 'Leave request for ${created.teacherName} submitted!',
      ));
    } catch (e) {
      emit(current.copyWith(
        actionSuccessMessage: 'Failed to apply leave: $e',
      ));
    }
  }

  List<StaffLeaveEntity> _applyFilters(
    List<StaffLeaveEntity> all,
    StaffLeaveStatus? status,
    String query,
  ) {
    var result = all;
    if (status != null) {
      result = result.where((l) => l.status == status).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((l) {
        return l.teacherName.toLowerCase().contains(q) ||
            l.staffCode.toString().contains(q) ||
            l.reason.toLowerCase().contains(q) ||
            l.leaveType.name.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }
}
