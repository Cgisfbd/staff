import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/domain/usecases/get_classes_usecase.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:staff_app/features/subjects/domain/entities/subject_entity.dart';
import 'package:staff_app/features/subjects/domain/usecases/subject_usecases.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_event.dart';
import 'package:staff_app/features/subjects/presentation/bloc/subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  SubjectBloc({
    required this.getSubjectsUseCase,
    required this.createSubjectUseCase,
    required this.updateSubjectUseCase,
    required this.deleteSubjectUseCase,
    required this.getCoursesUseCase,
    required this.getClassesUseCase,
  }) : super(const SubjectInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<FilterCourseSelectedEvent>(_onFilterCourseSelected);
    on<FilterClassSelectedEvent>(_onFilterClassSelected);
    on<SearchSubjectsEvent>(_onSearchSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
  }

  final GetSubjectsUseCase getSubjectsUseCase;
  final CreateSubjectUseCase createSubjectUseCase;
  final UpdateSubjectUseCase updateSubjectUseCase;
  final DeleteSubjectUseCase deleteSubjectUseCase;
  final GetCoursesUseCase getCoursesUseCase;
  final GetClassesUseCase getClassesUseCase;

  List<SubjectEntity> _allSubjects = [];
  List<CourseEntity> _allCourses = [];
  List<ClassEntity> _allClasses = [];

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(const SubjectLoading());
    try {
      final subjects = await getSubjectsUseCase(courseId: event.courseId, classId: event.classId);
      final coursesResult = await getCoursesUseCase();
      final classesResult = await getClassesUseCase();

      _allSubjects = subjects;
      _allCourses = coursesResult.fold((_) => <CourseEntity>[], (c) => c);
      _allClasses = classesResult.fold((_) => <ClassEntity>[], (c) => c);

      final filtered = _applyFilters(
        subjects: _allSubjects,
        courseId: event.courseId,
        classId: event.classId,
        query: '',
      );

      emit(SubjectLoaded(
        subjects: _allSubjects,
        filteredSubjects: filtered,
        courses: _allCourses,
        classes: _allClasses,
        selectedCourseId: event.courseId,
        selectedClassId: event.classId,
      ));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }

  void _onFilterCourseSelected(
    FilterCourseSelectedEvent event,
    Emitter<SubjectState> emit,
  ) {
    if (state is! SubjectLoaded) return;
    final curr = state as SubjectLoaded;

    final newCourseId = (event.courseId == 'ALL' || event.courseId == curr.selectedCourseId)
        ? null
        : event.courseId;

    // If changing course, reset class if it belongs to different course
    String? newClassId = curr.selectedClassId;
    if (newCourseId != null && newClassId != null) {
      final classMatches = _allClasses.any((c) => c.id == newClassId && c.courseId == newCourseId);
      if (!classMatches) newClassId = null;
    }

    final filtered = _applyFilters(
      subjects: _allSubjects,
      courseId: newCourseId,
      classId: newClassId,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      filteredSubjects: filtered,
      selectedCourseId: newCourseId,
      selectedClassId: newClassId,
      clearCourseFilter: newCourseId == null,
      clearClassFilter: newClassId == null,
    ));
  }

  void _onFilterClassSelected(
    FilterClassSelectedEvent event,
    Emitter<SubjectState> emit,
  ) {
    if (state is! SubjectLoaded) return;
    final curr = state as SubjectLoaded;

    final newClassId = (event.classId == 'ALL' || event.classId == curr.selectedClassId)
        ? null
        : event.classId;

    final filtered = _applyFilters(
      subjects: _allSubjects,
      courseId: curr.selectedCourseId,
      classId: newClassId,
      query: curr.searchQuery,
    );

    emit(curr.copyWith(
      filteredSubjects: filtered,
      selectedClassId: newClassId,
      clearClassFilter: newClassId == null,
    ));
  }

  void _onSearchSubjects(
    SearchSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) {
    if (state is! SubjectLoaded) return;
    final curr = state as SubjectLoaded;

    final filtered = _applyFilters(
      subjects: _allSubjects,
      courseId: curr.selectedCourseId,
      classId: curr.selectedClassId,
      query: event.query,
    );

    emit(curr.copyWith(
      filteredSubjects: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onCreateSubject(
    CreateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    if (state is! SubjectLoaded) return;
    final curr = state as SubjectLoaded;
    emit(curr.copyWith(isMutating: true));

    try {
      final created = await createSubjectUseCase(
        classId: event.classId,
        nameEnglish: event.nameEnglish,
        nameUrdu: event.nameUrdu,
      );

      _allSubjects = [created, ..._allSubjects];
      final filtered = _applyFilters(
        subjects: _allSubjects,
        courseId: curr.selectedCourseId,
        classId: curr.selectedClassId,
        query: curr.searchQuery,
      );

      emit(curr.copyWith(
        subjects: _allSubjects,
        filteredSubjects: filtered,
        isMutating: false,
        successMessage: 'Subject "${created.nameEnglish}" created successfully',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isMutating: false,
        errorMessage: 'Failed to create subject: $e',
      ));
    }
  }

  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    if (state is! SubjectLoaded) return;
    final curr = state as SubjectLoaded;
    emit(curr.copyWith(isMutating: true));

    try {
      final updated = await updateSubjectUseCase(
        id: event.id,
        classId: event.classId,
        nameEnglish: event.nameEnglish,
        nameUrdu: event.nameUrdu,
      );

      _allSubjects = _allSubjects.map((s) => s.id == updated.id ? updated : s).toList();
      final filtered = _applyFilters(
        subjects: _allSubjects,
        courseId: curr.selectedCourseId,
        classId: curr.selectedClassId,
        query: curr.searchQuery,
      );

      emit(curr.copyWith(
        subjects: _allSubjects,
        filteredSubjects: filtered,
        isMutating: false,
        successMessage: 'Subject "${updated.nameEnglish}" updated successfully',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isMutating: false,
        errorMessage: 'Failed to update subject: $e',
      ));
    }
  }

  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    if (state is! SubjectLoaded) return;
    final curr = state as SubjectLoaded;
    emit(curr.copyWith(isMutating: true));

    try {
      await deleteSubjectUseCase(id: event.id, pin: event.pin);

      _allSubjects = _allSubjects.where((s) => s.id != event.id).toList();
      final filtered = _applyFilters(
        subjects: _allSubjects,
        courseId: curr.selectedCourseId,
        classId: curr.selectedClassId,
        query: curr.searchQuery,
      );

      emit(curr.copyWith(
        subjects: _allSubjects,
        filteredSubjects: filtered,
        isMutating: false,
        successMessage: 'Subject deleted successfully',
      ));
    } catch (e) {
      emit(curr.copyWith(
        isMutating: false,
        errorMessage: 'Failed to delete subject: $e',
      ));
    }
  }

  List<SubjectEntity> _applyFilters({
    required List<SubjectEntity> subjects,
    String? courseId,
    String? classId,
    required String query,
  }) {
    return subjects.where((s) {
      if (classId != null && classId.isNotEmpty && s.classId != classId) {
        return false;
      }
      if (courseId != null && courseId.isNotEmpty) {
        // Match courseId directly or via class
        if (s.courseId != null && s.courseId != courseId) {
          return false;
        }
        if (s.courseId == null) {
          final parentClass = _allClasses.cast<ClassEntity?>().firstWhere(
                (c) => c?.id == s.classId,
                orElse: () => null,
              );
          if (parentClass != null && parentClass.courseId != courseId) {
            return false;
          }
        }
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchEn = s.nameEnglish.toLowerCase().contains(q);
        final matchUr = s.nameUrdu.toLowerCase().contains(q);
        final matchClass = s.className.toLowerCase().contains(q);
        if (!matchEn && !matchUr && !matchClass) return false;
      }
      return true;
    }).toList();
  }
}
