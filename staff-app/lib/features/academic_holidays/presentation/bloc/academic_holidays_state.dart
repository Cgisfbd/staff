import 'package:equatable/equatable.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

enum AcademicHolidaysStatus {
  initial,
  loading,
  loaded,
  saving,
  deleting,
  success,
  error,
}

class AcademicHolidaysState extends Equatable {
  const AcademicHolidaysState({
    required this.status,
    required this.holidays,
    required this.academicYearId,
    this.academicYearName,
    this.selectedCategory = 'ALL',
    this.searchQuery = '',
    this.errorMessage,
    this.actionMessage,
  });

  factory AcademicHolidaysState.initial() {
    return const AcademicHolidaysState(
      status: AcademicHolidaysStatus.initial,
      holidays: [],
      academicYearId: '',
      selectedCategory: 'ALL',
      searchQuery: '',
    );
  }

  final AcademicHolidaysStatus status;
  final List<AcademicHoliday> holidays;
  final String academicYearId;
  final String? academicYearName;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;
  final String? actionMessage;

  int get allCount => holidays.length;
  int get religiousCount => holidays.where((h) => h.type == HolidayType.religious).length;
  int get nationalCount => holidays.where((h) => h.type == HolidayType.national).length;
  int get institutionalCount => holidays.where((h) => h.type == HolidayType.institutional).length;

  List<AcademicHoliday> get filteredHolidays {
    return holidays.where((h) {
      final matchesCategory = selectedCategory == 'ALL' || h.type.value == selectedCategory;
      if (!matchesCategory) return false;

      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      final titleEn = h.titleEn.toLowerCase();
      final titleUr = h.titleUr.toLowerCase();
      final descEn = h.descEn.toLowerCase();

      return titleEn.contains(query) || titleUr.contains(query) || descEn.contains(query);
    }).toList();
  }

  int get totalDaysOff {
    return filteredHolidays.fold<int>(0, (sum, h) => sum + h.durationDays);
  }

  AcademicHolidaysState copyWith({
    AcademicHolidaysStatus? status,
    List<AcademicHoliday>? holidays,
    String? academicYearId,
    String? academicYearName,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
    String? actionMessage,
  }) {
    return AcademicHolidaysState(
      status: status ?? this.status,
      holidays: holidays ?? this.holidays,
      academicYearId: academicYearId ?? this.academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        holidays,
        academicYearId,
        academicYearName,
        selectedCategory,
        searchQuery,
        errorMessage,
        actionMessage,
      ];
}
