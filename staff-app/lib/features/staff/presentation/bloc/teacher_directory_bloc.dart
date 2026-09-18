import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';
import 'package:staff_app/features/staff/domain/repositories/teacher_directory_repository.dart';

// ── EVENTS ───────────────────────────────────────────────────────────────────
abstract class TeacherDirectoryEvent extends Equatable {
  const TeacherDirectoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeacherDirectoryEvent extends TeacherDirectoryEvent {
  const LoadTeacherDirectoryEvent();
}

class RefreshTeacherDirectoryEvent extends TeacherDirectoryEvent {
  const RefreshTeacherDirectoryEvent();
}

class SearchTeachersEvent extends TeacherDirectoryEvent {
  const SearchTeachersEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterTeachersEvent extends TeacherDirectoryEvent {
  const FilterTeachersEvent({
    this.designation,
    this.qualification,
    this.dutyMode,
    this.status,
  });

  final String? designation;
  final String? qualification;
  final String? dutyMode;
  final String? status;

  @override
  List<Object?> get props => [designation, qualification, dutyMode, status];
}

class CreateTeacherEvent extends TeacherDirectoryEvent {
  const CreateTeacherEvent(this.teacher);
  final TeacherDirectoryEntity teacher;

  @override
  List<Object?> get props => [teacher];
}

class UpdateTeacherEvent extends TeacherDirectoryEvent {
  const UpdateTeacherEvent(this.teacher);
  final TeacherDirectoryEntity teacher;

  @override
  List<Object?> get props => [teacher];
}

class DeleteTeacherEvent extends TeacherDirectoryEvent {
  const DeleteTeacherEvent(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

// ── STATES ───────────────────────────────────────────────────────────────────
abstract class TeacherDirectoryState extends Equatable {
  const TeacherDirectoryState();

  @override
  List<Object?> get props => [];
}

class TeacherDirectoryInitial extends TeacherDirectoryState {
  const TeacherDirectoryInitial();
}

class TeacherDirectoryLoading extends TeacherDirectoryState {
  const TeacherDirectoryLoading();
}

class TeacherDirectoryLoaded extends TeacherDirectoryState {
  const TeacherDirectoryLoaded({
    required this.teachers,
    required this.filteredTeachers,
    required this.stats,
    this.searchQuery = '',
    this.selectedDesignation = 'All',
    this.selectedQualification = 'All',
    this.selectedDutyMode = 'All',
    this.selectedStatus = 'All',
  });

  final List<TeacherDirectoryEntity> teachers;
  final List<TeacherDirectoryEntity> filteredTeachers;
  final TeacherStatsEntity stats;
  final String searchQuery;
  final String selectedDesignation;
  final String selectedQualification;
  final String selectedDutyMode;
  final String selectedStatus;

  TeacherDirectoryLoaded copyWith({
    List<TeacherDirectoryEntity>? teachers,
    List<TeacherDirectoryEntity>? filteredTeachers,
    TeacherStatsEntity? stats,
    String? searchQuery,
    String? selectedDesignation,
    String? selectedQualification,
    String? selectedDutyMode,
    String? selectedStatus,
  }) {
    return TeacherDirectoryLoaded(
      teachers: teachers ?? this.teachers,
      filteredTeachers: filteredTeachers ?? this.filteredTeachers,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDesignation: selectedDesignation ?? this.selectedDesignation,
      selectedQualification: selectedQualification ?? this.selectedQualification,
      selectedDutyMode: selectedDutyMode ?? this.selectedDutyMode,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  @override
  List<Object?> get props => [
        teachers,
        filteredTeachers,
        stats,
        searchQuery,
        selectedDesignation,
        selectedQualification,
        selectedDutyMode,
        selectedStatus,
      ];
}

class TeacherDirectoryError extends TeacherDirectoryState {
  const TeacherDirectoryError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLOC ─────────────────────────────────────────────────────────────────────
class TeacherDirectoryBloc extends Bloc<TeacherDirectoryEvent, TeacherDirectoryState> {
  TeacherDirectoryBloc({required TeacherDirectoryRepository repository})
      : _repository = repository,
        super(const TeacherDirectoryInitial()) {
    on<LoadTeacherDirectoryEvent>(_onLoad);
    on<RefreshTeacherDirectoryEvent>(_onRefresh);
    on<SearchTeachersEvent>(_onSearch);
    on<FilterTeachersEvent>(_onFilter);
    on<CreateTeacherEvent>(_onCreate);
    on<UpdateTeacherEvent>(_onUpdate);
    on<DeleteTeacherEvent>(_onDelete);
  }

  final TeacherDirectoryRepository _repository;

  Future<void> _onLoad(
    LoadTeacherDirectoryEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) async {
    emit(const TeacherDirectoryLoading());
    try {
      final results = await Future.wait([
        _repository.getTeachers(),
        _repository.getTeacherStats(),
      ]);
      final teachers = results[0] as List<TeacherDirectoryEntity>;
      final stats = results[1] as TeacherStatsEntity;

      emit(TeacherDirectoryLoaded(
        teachers: teachers,
        filteredTeachers: teachers,
        stats: stats,
      ));
    } catch (e) {
      emit(TeacherDirectoryError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshTeacherDirectoryEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _repository.getTeachers(),
        _repository.getTeacherStats(),
      ]);
      final teachers = results[0] as List<TeacherDirectoryEntity>;
      final stats = results[1] as TeacherStatsEntity;

      final cur = state;
      if (cur is TeacherDirectoryLoaded) {
        final filtered = _applyFilters(
          teachers,
          cur.searchQuery,
          cur.selectedDesignation,
          cur.selectedQualification,
          cur.selectedDutyMode,
          cur.selectedStatus,
        );
        emit(cur.copyWith(
          teachers: teachers,
          filteredTeachers: filtered,
          stats: stats,
        ));
      } else {
        emit(TeacherDirectoryLoaded(
          teachers: teachers,
          filteredTeachers: teachers,
          stats: stats,
        ));
      }
    } catch (e) {
      emit(TeacherDirectoryError(e.toString()));
    }
  }

  void _onSearch(
    SearchTeachersEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) {
    final cur = state;
    if (cur is! TeacherDirectoryLoaded) return;

    final filtered = _applyFilters(
      cur.teachers,
      event.query,
      cur.selectedDesignation,
      cur.selectedQualification,
      cur.selectedDutyMode,
      cur.selectedStatus,
    );
    emit(cur.copyWith(searchQuery: event.query, filteredTeachers: filtered));
  }

  void _onFilter(
    FilterTeachersEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) {
    final cur = state;
    if (cur is! TeacherDirectoryLoaded) return;

    final desig = event.designation ?? cur.selectedDesignation;
    final qual = event.qualification ?? cur.selectedQualification;
    final duty = event.dutyMode ?? cur.selectedDutyMode;
    final status = event.status ?? cur.selectedStatus;

    final filtered = _applyFilters(
      cur.teachers,
      cur.searchQuery,
      desig,
      qual,
      duty,
      status,
    );
    emit(cur.copyWith(
      selectedDesignation: desig,
      selectedQualification: qual,
      selectedDutyMode: duty,
      selectedStatus: status,
      filteredTeachers: filtered,
    ));
  }

  Future<void> _onCreate(
    CreateTeacherEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) async {
    try {
      await _repository.createTeacher(event.teacher);
      add(const RefreshTeacherDirectoryEvent());
    } catch (e) {
      emit(TeacherDirectoryError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateTeacherEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) async {
    try {
      await _repository.updateTeacher(event.teacher);
      add(const RefreshTeacherDirectoryEvent());
    } catch (e) {
      emit(TeacherDirectoryError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteTeacherEvent event,
    Emitter<TeacherDirectoryState> emit,
  ) async {
    try {
      await _repository.deleteTeacher(event.id);
      add(const RefreshTeacherDirectoryEvent());
    } catch (e) {
      emit(TeacherDirectoryError(e.toString()));
    }
  }

  List<TeacherDirectoryEntity> _applyFilters(
    List<TeacherDirectoryEntity> list,
    String query,
    String desig,
    String qual,
    String duty,
    String status,
  ) {
    var res = list;
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      res = res.where((t) {
        return t.fullNameEn.toLowerCase().contains(q) ||
            t.nameUrdu.contains(q) ||
            t.staffCode.toString().contains(q) ||
            t.rfidNo.toLowerCase().contains(q) ||
            t.phone.contains(q) ||
            t.designation.toLowerCase().contains(q) ||
            t.qualification.toLowerCase().contains(q);
      }).toList();
    }
    if (desig != 'All' && desig.isNotEmpty) {
      res = res.where((t) => t.designation.toLowerCase().contains(desig.toLowerCase())).toList();
    }
    if (qual != 'All' && qual.isNotEmpty) {
      res = res.where((t) => t.qualification.toLowerCase().contains(qual.toLowerCase())).toList();
    }
    if (duty != 'All' && duty.isNotEmpty) {
      res = res.where((t) => t.dutyMode.toLowerCase().contains(duty.toLowerCase())).toList();
    }
    if (status != 'All' && status.isNotEmpty) {
      res = res.where((t) => t.status.toLowerCase() == status.toLowerCase()).toList();
    }
    return res;
  }
}
