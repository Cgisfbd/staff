import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/features/academic_holidays/domain/repositories/academic_holidays_repository.dart';
import 'package:staff_app/features/academic_holidays/presentation/bloc/academic_holidays_event.dart';
import 'package:staff_app/features/academic_holidays/presentation/bloc/academic_holidays_state.dart';
import 'package:staff_app/features/academic_sessions/domain/repositories/academic_session_repository.dart';

class AcademicHolidaysBloc extends Bloc<AcademicHolidaysEvent, AcademicHolidaysState> {
  AcademicHolidaysBloc({
    required this.academicHolidaysRepository,
    required this.academicSessionRepository,
  }) : super(AcademicHolidaysState.initial()) {
    on<LoadHolidaysEvent>(_onLoadHolidays);
    on<FilterCategoryEvent>(_onFilterCategory);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<CreateHolidayEvent>(_onCreateHoliday);
    on<UpdateHolidayEvent>(_onUpdateHoliday);
    on<DeleteHolidayEvent>(_onDeleteHoliday);
  }

  final AcademicHolidaysRepository academicHolidaysRepository;
  final AcademicSessionRepository academicSessionRepository;

  Future<void> _onLoadHolidays(
    LoadHolidaysEvent event,
    Emitter<AcademicHolidaysState> emit,
  ) async {
    String yearId = event.academicYearId ?? state.academicYearId;
    String? yearName = state.academicYearName;

    if (yearId.isEmpty) {
      yearId = '2071013f-1144-4980-9901-3e51b2f2e487';
      yearName = '1446-1447 AH (2025-2026)';
    }

    try {
      final sessionsResult = await academicSessionRepository
          .getAcademicSessions()
          .timeout(const Duration(seconds: 2));

      sessionsResult.fold(
        (_) {},
        (sessions) {
          if (sessions.isNotEmpty) {
            final active = sessions.firstWhere(
              (s) => s.isActive,
              orElse: () => sessions.first,
            );
            yearId = active.id;
            yearName = active.yearName;
          }
        },
      );
    } catch (_) {}

    emit(state.copyWith(
      status: AcademicHolidaysStatus.loading,
      academicYearId: yearId,
      academicYearName: yearName,
    ));

    final result = await academicHolidaysRepository.getHolidays(
      academicYearId: yearId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AcademicHolidaysStatus.error,
        errorMessage: failure.message,
      )),
      (holidays) => emit(state.copyWith(
        status: AcademicHolidaysStatus.loaded,
        holidays: holidays,
      )),
    );
  }

  void _onFilterCategory(
    FilterCategoryEvent event,
    Emitter<AcademicHolidaysState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<AcademicHolidaysState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onCreateHoliday(
    CreateHolidayEvent event,
    Emitter<AcademicHolidaysState> emit,
  ) async {
    emit(state.copyWith(status: AcademicHolidaysStatus.saving));

    final result = await academicHolidaysRepository.createHoliday(
      academicYearId: state.academicYearId,
      holiday: event.holiday,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AcademicHolidaysStatus.error,
        errorMessage: failure.message,
      )),
      (created) {
        final updatedList = [created, ...state.holidays];
        emit(state.copyWith(
          status: AcademicHolidaysStatus.success,
          holidays: updatedList,
          actionMessage: 'Holiday "${created.titleEn}" added to calendar!',
        ));
      },
    );
  }

  Future<void> _onUpdateHoliday(
    UpdateHolidayEvent event,
    Emitter<AcademicHolidaysState> emit,
  ) async {
    emit(state.copyWith(status: AcademicHolidaysStatus.saving));

    final result = await academicHolidaysRepository.updateHoliday(
      id: event.id,
      holiday: event.holiday,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AcademicHolidaysStatus.error,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedList = state.holidays
            .map((h) => h.id == event.id ? updated : h)
            .toList();
        emit(state.copyWith(
          status: AcademicHolidaysStatus.success,
          holidays: updatedList,
          actionMessage: 'Holiday updated successfully!',
        ));
      },
    );
  }

  Future<void> _onDeleteHoliday(
    DeleteHolidayEvent event,
    Emitter<AcademicHolidaysState> emit,
  ) async {
    emit(state.copyWith(status: AcademicHolidaysStatus.deleting));

    final result = await academicHolidaysRepository.deleteHoliday(
      id: event.id,
      pin: event.pin,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AcademicHolidaysStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedList = state.holidays.where((h) => h.id != event.id).toList();
        emit(state.copyWith(
          status: AcademicHolidaysStatus.success,
          holidays: updatedList,
          actionMessage: 'Holiday deleted from calendar!',
        ));
      },
    );
  }
}
