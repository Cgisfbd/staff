import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';
import 'package:staff_app/features/staff/domain/repositories/staff_duty_repository.dart';

// ── EVENTS ───────────────────────────────────────────────────────────────────
abstract class StaffDutyEvent extends Equatable {
  const StaffDutyEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffDutiesEvent extends StaffDutyEvent {
  const LoadStaffDutiesEvent();
}

class RefreshStaffDutiesEvent extends StaffDutyEvent {
  const RefreshStaffDutiesEvent();
}

class SearchStaffDutiesEvent extends StaffDutyEvent {
  const SearchStaffDutiesEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterStaffDutiesEvent extends StaffDutyEvent {
  const FilterStaffDutiesEvent({
    this.status,
    this.className,
  });

  final String? status;
  final String? className;

  @override
  List<Object?> get props => [status, className];
}

class SaveStaffDutyEvent extends StaffDutyEvent {
  const SaveStaffDutyEvent({
    required this.facultyId,
    required this.assignedClasses,
    required this.assignedBooks,
  });

  final String facultyId;
  final List<String> assignedClasses;
  final List<TeachingBookItem> assignedBooks;

  @override
  List<Object?> get props => [facultyId, assignedClasses, assignedBooks];
}

// ── STATES ───────────────────────────────────────────────────────────────────
abstract class StaffDutyState extends Equatable {
  const StaffDutyState();

  @override
  List<Object?> get props => [];
}

class StaffDutyInitial extends StaffDutyState {
  const StaffDutyInitial();
}

class StaffDutyLoading extends StaffDutyState {
  const StaffDutyLoading();
}

class StaffDutyLoaded extends StaffDutyState {
  const StaffDutyLoaded({
    required this.duties,
    required this.filteredDuties,
    required this.stats,
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedClass = 'All',
    this.isSaving = false,
    this.saveSuccessMessage,
  });

  final List<StaffDutyEntity> duties;
  final List<StaffDutyEntity> filteredDuties;
  final StaffDutyStatsEntity stats;
  final String searchQuery;
  final String selectedStatus;
  final String selectedClass;
  final bool isSaving;
  final String? saveSuccessMessage;

  StaffDutyLoaded copyWith({
    List<StaffDutyEntity>? duties,
    List<StaffDutyEntity>? filteredDuties,
    StaffDutyStatsEntity? stats,
    String? searchQuery,
    String? selectedStatus,
    String? selectedClass,
    bool? isSaving,
    String? saveSuccessMessage,
  }) {
    return StaffDutyLoaded(
      duties: duties ?? this.duties,
      filteredDuties: filteredDuties ?? this.filteredDuties,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedClass: selectedClass ?? this.selectedClass,
      isSaving: isSaving ?? this.isSaving,
      saveSuccessMessage: saveSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        duties,
        filteredDuties,
        stats,
        searchQuery,
        selectedStatus,
        selectedClass,
        isSaving,
        saveSuccessMessage,
      ];
}

class StaffDutyError extends StaffDutyState {
  const StaffDutyError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLOC ─────────────────────────────────────────────────────────────────────
class StaffDutyBloc extends Bloc<StaffDutyEvent, StaffDutyState> {
  StaffDutyBloc({required StaffDutyRepository repository})
      : _repository = repository,
        super(const StaffDutyInitial()) {
    on<LoadStaffDutiesEvent>(_onLoad);
    on<RefreshStaffDutiesEvent>(_onRefresh);
    on<SearchStaffDutiesEvent>(_onSearch);
    on<FilterStaffDutiesEvent>(_onFilter);
    on<SaveStaffDutyEvent>(_onSave);
  }

  final StaffDutyRepository _repository;

  Future<void> _onLoad(
    LoadStaffDutiesEvent event,
    Emitter<StaffDutyState> emit,
  ) async {
    emit(const StaffDutyLoading());
    try {
      final results = await Future.wait([
        _repository.getStaffDuties(),
        _repository.getStaffDutyStats(),
      ]);
      final duties = results[0] as List<StaffDutyEntity>;
      final stats = results[1] as StaffDutyStatsEntity;

      emit(StaffDutyLoaded(
        duties: duties,
        filteredDuties: duties,
        stats: stats,
      ));
    } catch (e) {
      emit(StaffDutyError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshStaffDutiesEvent event,
    Emitter<StaffDutyState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _repository.getStaffDuties(),
        _repository.getStaffDutyStats(),
      ]);
      final duties = results[0] as List<StaffDutyEntity>;
      final stats = results[1] as StaffDutyStatsEntity;

      final cur = state;
      if (cur is StaffDutyLoaded) {
        final filtered = _applyFilters(
          duties,
          cur.searchQuery,
          cur.selectedStatus,
          cur.selectedClass,
        );
        emit(cur.copyWith(
          duties: duties,
          filteredDuties: filtered,
          stats: stats,
        ));
      } else {
        emit(StaffDutyLoaded(
          duties: duties,
          filteredDuties: duties,
          stats: stats,
        ));
      }
    } catch (e) {
      emit(StaffDutyError(e.toString()));
    }
  }

  void _onSearch(
    SearchStaffDutiesEvent event,
    Emitter<StaffDutyState> emit,
  ) {
    final cur = state;
    if (cur is! StaffDutyLoaded) return;

    final filtered = _applyFilters(
      cur.duties,
      event.query,
      cur.selectedStatus,
      cur.selectedClass,
    );
    emit(cur.copyWith(searchQuery: event.query, filteredDuties: filtered));
  }

  void _onFilter(
    FilterStaffDutiesEvent event,
    Emitter<StaffDutyState> emit,
  ) {
    final cur = state;
    if (cur is! StaffDutyLoaded) return;

    final status = event.status ?? cur.selectedStatus;
    final cls = event.className ?? cur.selectedClass;

    final filtered = _applyFilters(
      cur.duties,
      cur.searchQuery,
      status,
      cls,
    );
    emit(cur.copyWith(
      selectedStatus: status,
      selectedClass: cls,
      filteredDuties: filtered,
    ));
  }

  Future<void> _onSave(
    SaveStaffDutyEvent event,
    Emitter<StaffDutyState> emit,
  ) async {
    final cur = state;
    if (cur is! StaffDutyLoaded) return;

    emit(cur.copyWith(isSaving: true, saveSuccessMessage: null));
    try {
      final updated = await _repository.updateStaffDuty(
        facultyId: event.facultyId,
        assignedClasses: event.assignedClasses,
        assignedBooks: event.assignedBooks,
      );

      final updatedList = cur.duties.map((d) {
        return d.facultyId == updated.facultyId ? updated : d;
      }).toList();

      final newStats = await _repository.getStaffDutyStats();
      final filtered = _applyFilters(
        updatedList,
        cur.searchQuery,
        cur.selectedStatus,
        cur.selectedClass,
      );

      emit(cur.copyWith(
        duties: updatedList,
        filteredDuties: filtered,
        stats: newStats,
        isSaving: false,
        saveSuccessMessage: 'Duty allocation saved for ${updated.fullNameEn}!',
      ));
    } catch (e) {
      emit(cur.copyWith(isSaving: false));
      emit(StaffDutyError('Failed to save duty: $e'));
    }
  }

  List<StaffDutyEntity> _applyFilters(
    List<StaffDutyEntity> list,
    String query,
    String status,
    String className,
  ) {
    var res = list;
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      res = res.where((d) {
        return d.fullNameEn.toLowerCase().contains(q) ||
            d.fullNameUr.contains(q) ||
            d.staffCode.toString().contains(q) ||
            d.designation.toLowerCase().contains(q) ||
            d.assignedClasses.any((c) => c.toLowerCase().contains(q)) ||
            d.assignedBooks.any((b) => b.bookName.toLowerCase().contains(q));
      }).toList();
    }

    if (status == 'Configured') {
      res = res.where((d) => d.isDutyConfigured && (d.assignedClasses.isNotEmpty || d.assignedBooks.isNotEmpty)).toList();
    } else if (status == 'Pending') {
      res = res.where((d) => !d.isDutyConfigured || (d.assignedClasses.isEmpty && d.assignedBooks.isEmpty)).toList();
    }

    if (className != 'All' && className.isNotEmpty) {
      res = res.where((d) => d.assignedClasses.contains(className)).toList();
    }

    return res;
  }
}
