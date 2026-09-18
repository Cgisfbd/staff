import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/domain/usecases/get_student_stats_usecase.dart';
import 'package:staff_app/features/students/domain/usecases/get_students_usecase.dart';

// ── EVENTS ───────────────────────────────────────────────────────────────────
abstract class StudentDirectoryEvent extends Equatable {
  const StudentDirectoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudentDirectoryEvent extends StudentDirectoryEvent {
  const LoadStudentDirectoryEvent();
}

class RefreshStudentDirectoryEvent extends StudentDirectoryEvent {
  const RefreshStudentDirectoryEvent();
}

class SearchStudentsEvent extends StudentDirectoryEvent {
  const SearchStudentsEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterStudentsEvent extends StudentDirectoryEvent {
  const FilterStudentsEvent({
    this.status,
    this.mode,
    this.course,
  });

  final String? status;
  final String? mode;
  final String? course;

  @override
  List<Object?> get props => [status, mode, course];
}

// ── STATES ───────────────────────────────────────────────────────────────────
abstract class StudentDirectoryState extends Equatable {
  const StudentDirectoryState();

  @override
  List<Object?> get props => [];
}

class StudentDirectoryInitial extends StudentDirectoryState {
  const StudentDirectoryInitial();
}

class StudentDirectoryLoading extends StudentDirectoryState {
  const StudentDirectoryLoading();
}

class StudentDirectoryLoaded extends StudentDirectoryState {
  const StudentDirectoryLoaded({
    required this.students,
    required this.filteredStudents,
    required this.stats,
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedMode = 'All',
    this.selectedCourse = 'All',
  });

  final List<StudentDirectoryEntity> students;
  final List<StudentDirectoryEntity> filteredStudents;
  final StudentStatsEntity stats;
  final String searchQuery;
  final String selectedStatus;
  final String selectedMode;
  final String selectedCourse;

  StudentDirectoryLoaded copyWith({
    List<StudentDirectoryEntity>? students,
    List<StudentDirectoryEntity>? filteredStudents,
    StudentStatsEntity? stats,
    String? searchQuery,
    String? selectedStatus,
    String? selectedMode,
    String? selectedCourse,
  }) {
    return StudentDirectoryLoaded(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }

  @override
  List<Object?> get props => [
        students,
        filteredStudents,
        stats,
        searchQuery,
        selectedStatus,
        selectedMode,
        selectedCourse,
      ];
}

class StudentDirectoryError extends StudentDirectoryState {
  const StudentDirectoryError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLOC ─────────────────────────────────────────────────────────────────────
class StudentDirectoryBloc
    extends Bloc<StudentDirectoryEvent, StudentDirectoryState> {
  StudentDirectoryBloc({
    required GetStudentsUseCase getStudentsUseCase,
    required GetStudentStatsUseCase getStudentStatsUseCase,
  })  : _getStudentsUseCase = getStudentsUseCase,
        _getStudentStatsUseCase = getStudentStatsUseCase,
        super(const StudentDirectoryInitial()) {
    on<LoadStudentDirectoryEvent>(_onLoad);
    on<RefreshStudentDirectoryEvent>(_onRefresh);
    on<SearchStudentsEvent>(_onSearch);
    on<FilterStudentsEvent>(_onFilter);
  }

  final GetStudentsUseCase _getStudentsUseCase;
  final GetStudentStatsUseCase _getStudentStatsUseCase;

  Future<void> _onLoad(
    LoadStudentDirectoryEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    emit(const StudentDirectoryLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    RefreshStudentDirectoryEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<StudentDirectoryState> emit) async {
    try {
      final results = await Future.wait([
        _getStudentsUseCase(),
        _getStudentStatsUseCase(),
      ]);

      final students = results[0] as List<StudentDirectoryEntity>;
      final stats = results[1] as StudentStatsEntity;

      emit(
        StudentDirectoryLoaded(
          students: students,
          filteredStudents: students,
          stats: stats,
        ),
      );
    } catch (e) {
      emit(StudentDirectoryError(e.toString()));
    }
  }

  void _onSearch(
    SearchStudentsEvent event,
    Emitter<StudentDirectoryState> emit,
  ) {
    final current = state;
    if (current is StudentDirectoryLoaded) {
      final filtered = _applyFilters(
        all: current.students,
        query: event.query,
        status: current.selectedStatus,
        mode: current.selectedMode,
        course: current.selectedCourse,
      );
      emit(
        current.copyWith(
          searchQuery: event.query,
          filteredStudents: filtered,
        ),
      );
    }
  }

  void _onFilter(
    FilterStudentsEvent event,
    Emitter<StudentDirectoryState> emit,
  ) {
    final current = state;
    if (current is StudentDirectoryLoaded) {
      final newStatus = event.status ?? current.selectedStatus;
      final newMode = event.mode ?? current.selectedMode;
      final newCourse = event.course ?? current.selectedCourse;

      final filtered = _applyFilters(
        all: current.students,
        query: current.searchQuery,
        status: newStatus,
        mode: newMode,
        course: newCourse,
      );

      emit(
        current.copyWith(
          selectedStatus: newStatus,
          selectedMode: newMode,
          selectedCourse: newCourse,
          filteredStudents: filtered,
        ),
      );
    }
  }

  List<StudentDirectoryEntity> _applyFilters({
    required List<StudentDirectoryEntity> all,
    required String query,
    required String status,
    required String mode,
    required String course,
  }) {
    return all.where((s) {
      final matchesQuery = query.trim().isEmpty ||
          s.fullNameEn.toLowerCase().contains(query.toLowerCase().trim()) ||
          s.nameUrdu.contains(query.trim()) ||
          s.rollNo.toString().contains(query.trim()) ||
          s.rfidNo.toLowerCase().contains(query.toLowerCase().trim()) ||
          s.fatherNameEn.toLowerCase().contains(query.toLowerCase().trim()) ||
          s.mobile.contains(query.trim());

      final matchesStatus = status == 'All' ||
          s.status.toLowerCase() == status.toLowerCase() ||
          (status.toLowerCase() == 'suspend' && s.status.toLowerCase() == 'suspended') ||
          (status.toLowerCase() == 'suspended' && s.status.toLowerCase() == 'suspend') ||
          (status.toLowerCase() == 'graduate' && s.status.toLowerCase() == 'graduated') ||
          (status.toLowerCase() == 'graduated' && s.status.toLowerCase() == 'graduate');

      final matchesMode = mode == 'All' ||
          s.modeOfStudy.toLowerCase() == mode.toLowerCase();

      final matchesCourse = course == 'All' ||
          s.courseName.toLowerCase() == course.toLowerCase();

      return matchesQuery && matchesStatus && matchesMode && matchesCourse;
    }).toList();
  }
}
