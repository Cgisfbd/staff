import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/classes/domain/entities/class_entity.dart';
import 'package:staff_app/features/classes/domain/usecases/get_classes_usecase.dart';
import 'package:staff_app/features/courses/domain/entities/course_entity.dart';
import 'package:staff_app/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:staff_app/features/fee_structure/domain/entities/fee_structure_entity.dart';
import 'package:staff_app/features/fee_structure/domain/repositories/fee_structure_repository.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_event.dart';
import 'package:staff_app/features/fee_structure/presentation/bloc/fee_structure_state.dart';

class FeeStructureBloc extends Bloc<FeeStructureEvent, FeeStructureState> {
  FeeStructureBloc({
    required this.feeStructureRepository,
    required this.getCoursesUseCase,
    required this.getClassesUseCase,
  }) : super(const FeeStructureInitial()) {
    on<LoadFeeStructuresEvent>(_onLoadFees);
    on<FilterFeeStructuresByCourseEvent>(_onFilterByCourse);
    on<SearchFeeStructuresEvent>(_onSearch);
    on<SaveFeeStructureEvent>(_onSaveFee);
    on<DeleteFeeStructureEvent>(_onDeleteFee);
  }

  final FeeStructureRepository feeStructureRepository;
  final GetCoursesUseCase getCoursesUseCase;
  final GetClassesUseCase getClassesUseCase;

  Future<void> _onLoadFees(
    LoadFeeStructuresEvent event,
    Emitter<FeeStructureState> emit,
  ) async {
    emit(const FeeStructureLoading());
    try {
      final coursesRes = await getCoursesUseCase();
      final courses = coursesRes.fold((_) => <CourseEntity>[], (c) => c);

      final classesRes = await getClassesUseCase();
      final classes = classesRes.fold((_) => <ClassEntity>[], (cl) => cl);

      final fees = await feeStructureRepository.getFees(courseId: event.courseId);

      emit(FeeStructureLoaded(
        fees: fees,
        classes: classes,
        courses: courses,
        selectedCourseId: event.courseId ?? 'ALL',
      ));
    } catch (e) {
      emit(FeeStructureError(e.toString()));
    }
  }

  void _onFilterByCourse(
    FilterFeeStructuresByCourseEvent event,
    Emitter<FeeStructureState> emit,
  ) {
    if (state is FeeStructureLoaded) {
      final current = state as FeeStructureLoaded;
      emit(current.copyWith(selectedCourseId: event.courseId));
    }
  }

  void _onSearch(
    SearchFeeStructuresEvent event,
    Emitter<FeeStructureState> emit,
  ) {
    if (state is FeeStructureLoaded) {
      final current = state as FeeStructureLoaded;
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onSaveFee(
    SaveFeeStructureEvent event,
    Emitter<FeeStructureState> emit,
  ) async {
    if (state is FeeStructureLoaded) {
      final current = state as FeeStructureLoaded;
      try {
        final saved = await feeStructureRepository.saveFeeStructure(
          classId: event.classId,
          className: event.className,
          id: event.id,
          tuitionFee: event.tuitionFee,
          hostelFee: event.hostelFee,
          admissionFeeHostel: event.admissionFeeHostel,
          admissionFeeNonHostel: event.admissionFeeNonHostel,
          admissionRenewalFee: event.admissionRenewalFee,
          examFee: event.examFee,
          onlineFee: event.onlineFee,
          onlineAdmissionFee: event.onlineAdmissionFee,
        );

        final updatedFees = List<FeeStructureEntity>.from(current.fees)
          ..removeWhere((f) => f.classId == event.classId)
          ..add(saved);

        emit(current.copyWith(
          fees: updatedFees,
          statusMessage: 'Fee structure saved for ${event.className}',
        ));
      } catch (e) {
        emit(FeeStructureError('Failed to save fee structure: $e'));
      }
    }
  }

  Future<void> _onDeleteFee(
    DeleteFeeStructureEvent event,
    Emitter<FeeStructureState> emit,
  ) async {
    if (state is FeeStructureLoaded) {
      final current = state as FeeStructureLoaded;
      try {
        await feeStructureRepository.deleteFeeStructure(event.id);
        final updatedFees = List<FeeStructureEntity>.from(current.fees)
          ..removeWhere((f) => f.id == event.id);

        emit(current.copyWith(
          fees: updatedFees,
          statusMessage: 'Fee structure deleted',
        ));
      } catch (e) {
        emit(FeeStructureError('Failed to delete fee structure: $e'));
      }
    }
  }
}
