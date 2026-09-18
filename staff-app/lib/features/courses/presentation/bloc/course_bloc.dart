import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:staff_app/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:staff_app/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:staff_app/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:staff_app/features/courses/presentation/bloc/course_event.dart';
import 'package:staff_app/features/courses/presentation/bloc/course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc({
    required this.getCoursesUseCase,
    required this.createCourseUseCase,
    required this.updateCourseUseCase,
    required this.deleteCourseUseCase,
  }) : super(const CourseInitial()) {
    on<LoadCoursesEvent>(_onLoadCourses);
    on<ToggleExpandCourseEvent>(_onToggleExpandCourse);
    on<CreateCourseEvent>(_onCreateCourse);
    on<UpdateCourseEvent>(_onUpdateCourse);
    on<DeleteCourseEvent>(_onDeleteCourse);
  }

  final GetCoursesUseCase getCoursesUseCase;
  final CreateCourseUseCase createCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  List<CourseEntity> _filter(List<CourseEntity> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase().trim();
    return list.where((c) {
      final en = c.nameEnglish.toLowerCase();
      final ur = (c.nameUrdu ?? '').toLowerCase();
      final desc = (c.description ?? '').toLowerCase();
      return en.contains(q) || ur.contains(q) || desc.contains(q);
    }).toList();
  }

  Future<void> _onLoadCourses(
    LoadCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(const CourseLoading());
    final result = await getCoursesUseCase();

    result.fold(
      (failure) => emit(CourseError(failure.message)),
      (courses) {
        final query = event.searchQuery ?? '';
        final filtered = _filter(courses, query);
        final firstId = courses.isNotEmpty ? courses.first.id : null;

        emit(CourseLoaded(
          courses: courses,
          filteredCourses: filtered,
          expandedCourseId: firstId,
          searchQuery: query,
        ));
      },
    );
  }

  void _onToggleExpandCourse(
    ToggleExpandCourseEvent event,
    Emitter<CourseState> emit,
  ) {
    if (state is CourseLoaded) {
      final current = state as CourseLoaded;
      final newId = current.expandedCourseId == event.courseId ? null : event.courseId;
      emit(current.copyWith(expandedCourseId: () => newId));
    }
  }

  Future<void> _onCreateCourse(
    CreateCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    if (state is! CourseLoaded) return;
    final current = state as CourseLoaded;
    emit(current.copyWith(isActionLoading: true));

    final result = await createCourseUseCase(
      nameEnglish: event.nameEnglish,
      nameUrdu: event.nameUrdu,
      description: event.description,
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(isActionLoading: false));
      },
      (newCourse) async {
        final refresh = await getCoursesUseCase();
        refresh.fold(
          (f) => emit(current.copyWith(isActionLoading: false)),
          (updated) {
            emit(CourseLoaded(
              courses: updated,
              filteredCourses: _filter(updated, current.searchQuery),
              expandedCourseId: newCourse.id,
              searchQuery: current.searchQuery,
              isActionLoading: false,
              actionSuccessMessage: 'Course "${newCourse.nameEnglish}" created successfully!',
            ));
          },
        );
      },
    );
  }

  Future<void> _onUpdateCourse(
    UpdateCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    if (state is! CourseLoaded) return;
    final current = state as CourseLoaded;
    emit(current.copyWith(isActionLoading: true));

    final result = await updateCourseUseCase(
      id: event.id,
      nameEnglish: event.nameEnglish,
      nameUrdu: event.nameUrdu,
      description: event.description,
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(isActionLoading: false));
      },
      (updatedCourse) async {
        final refresh = await getCoursesUseCase();
        refresh.fold(
          (f) => emit(current.copyWith(isActionLoading: false)),
          (updated) {
            emit(CourseLoaded(
              courses: updated,
              filteredCourses: _filter(updated, current.searchQuery),
              expandedCourseId: updatedCourse.id,
              searchQuery: current.searchQuery,
              isActionLoading: false,
              actionSuccessMessage: 'Course "${updatedCourse.nameEnglish}" updated successfully!',
            ));
          },
        );
      },
    );
  }

  Future<void> _onDeleteCourse(
    DeleteCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    if (state is! CourseLoaded) return;
    final current = state as CourseLoaded;
    emit(current.copyWith(isActionLoading: true));

    final result = await deleteCourseUseCase(id: event.id, pin: event.pin);

    await result.fold(
      (failure) async {
        emit(current.copyWith(isActionLoading: false));
      },
      (_) async {
        final refresh = await getCoursesUseCase();
        refresh.fold(
          (f) => emit(current.copyWith(isActionLoading: false)),
          (updated) {
            emit(CourseLoaded(
              courses: updated,
              filteredCourses: _filter(updated, current.searchQuery),
              expandedCourseId: updated.isNotEmpty ? updated.first.id : null,
              searchQuery: current.searchQuery,
              isActionLoading: false,
              actionSuccessMessage: 'Course removed permanently.',
            ));
          },
        );
      },
    );
  }
}
