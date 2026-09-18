import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/classes/domain/usecases/create_class_usecase.dart';
import 'package:staff_app/features/classes/domain/usecases/delete_class_usecase.dart';
import 'package:staff_app/features/classes/domain/usecases/get_classes_usecase.dart';
import 'package:staff_app/features/classes/domain/usecases/update_class_usecase.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_event.dart';
import 'package:staff_app/features/classes/presentation/bloc/class_state.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/usecases/get_courses_usecase.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  ClassBloc({
    required this.getClassesUseCase,
    required this.getCoursesUseCase,
    required this.createClassUseCase,
    required this.updateClassUseCase,
    required this.deleteClassUseCase,
  }) : super(const ClassInitial()) {
    on<LoadClassesEvent>(_onLoadClasses);
    on<SelectCourseFilterEvent>(_onSelectCourseFilter);
    on<ToggleExpandClassEvent>(_onToggleExpandClass);
    on<CreateClassEvent>(_onCreateClass);
    on<UpdateClassEvent>(_onUpdateClass);
    on<DeleteClassEvent>(_onDeleteClass);
  }

  final GetClassesUseCase getClassesUseCase;
  final GetCoursesUseCase getCoursesUseCase;
  final CreateClassUseCase createClassUseCase;
  final UpdateClassUseCase updateClassUseCase;
  final DeleteClassUseCase deleteClassUseCase;

  Future<void> _onLoadClasses(
    LoadClassesEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoading());

    final coursesResult = await getCoursesUseCase();
    final List<CourseEntity> courses = coursesResult.fold((_) => [], (c) => c);

    final classesResult = await getClassesUseCase(courseId: event.courseId);

    classesResult.fold(
      (failure) => emit(ClassError(failure.message)),
      (classes) {
        final query = event.searchQuery ?? '';
        final firstId = classes.isNotEmpty ? classes.first.id : null;

        emit(ClassLoaded(
          classes: classes,
          courses: courses,
          selectedCourseId: event.courseId ?? 'ALL',
          searchQuery: query,
          expandedClassId: firstId,
        ));
      },
    );
  }

  void _onSelectCourseFilter(
    SelectCourseFilterEvent event,
    Emitter<ClassState> emit,
  ) {
    if (state is ClassLoaded) {
      final current = state as ClassLoaded;
      emit(current.copyWith(
        selectedCourseId: event.courseId,
        expandedClassId: () => null,
      ));
    }
  }

  void _onToggleExpandClass(
    ToggleExpandClassEvent event,
    Emitter<ClassState> emit,
  ) {
    if (state is ClassLoaded) {
      final current = state as ClassLoaded;
      final newId = current.expandedClassId == event.classId ? null : event.classId;
      emit(current.copyWith(expandedClassId: () => newId));
    }
  }

  Future<void> _onCreateClass(
    CreateClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    if (state is! ClassLoaded) return;
    final current = state as ClassLoaded;

    final result = await createClassUseCase(
      courseId: event.courseId,
      nameEnglish: event.nameEnglish,
      nameUrdu: event.nameUrdu,
      capacity: event.capacity,
    );

    await result.fold(
      (failure) async {
        emit(ClassError(failure.message));
      },
      (newClass) async {
        final refresh = await getClassesUseCase();
        refresh.fold(
          (f) => null,
          (updated) {
            emit(ClassLoaded(
              classes: updated,
              courses: current.courses,
              selectedCourseId: current.selectedCourseId,
              searchQuery: current.searchQuery,
              expandedClassId: newClass.id,
              actionSuccessMessage: 'Class "${newClass.nameEnglish}" registered successfully',
            ));
          },
        );
      },
    );
  }

  Future<void> _onUpdateClass(
    UpdateClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    if (state is! ClassLoaded) return;
    final current = state as ClassLoaded;

    final result = await updateClassUseCase(
      id: event.id,
      courseId: event.courseId,
      nameEnglish: event.nameEnglish,
      nameUrdu: event.nameUrdu,
      capacity: event.capacity,
    );

    await result.fold(
      (failure) async {
        emit(ClassError(failure.message));
      },
      (updatedClass) async {
        final refresh = await getClassesUseCase();
        refresh.fold(
          (f) => null,
          (updated) {
            emit(ClassLoaded(
              classes: updated,
              courses: current.courses,
              selectedCourseId: current.selectedCourseId,
              searchQuery: current.searchQuery,
              expandedClassId: updatedClass.id,
              actionSuccessMessage: 'Class "${updatedClass.nameEnglish}" updated successfully',
            ));
          },
        );
      },
    );
  }

  Future<void> _onDeleteClass(
    DeleteClassEvent event,
    Emitter<ClassState> emit,
  ) async {
    if (state is! ClassLoaded) return;
    final current = state as ClassLoaded;

    final result = await deleteClassUseCase(
      id: event.id,
      pin: event.pin,
    );

    await result.fold(
      (failure) async {
        emit(ClassError(failure.message));
      },
      (_) async {
        final refresh = await getClassesUseCase();
        refresh.fold(
          (f) => null,
          (updated) {
            emit(ClassLoaded(
              classes: updated,
              courses: current.courses,
              selectedCourseId: current.selectedCourseId,
              searchQuery: current.searchQuery,
              expandedClassId: null,
              actionSuccessMessage: 'Class removed permanently',
            ));
          },
        );
      },
    );
  }
}
