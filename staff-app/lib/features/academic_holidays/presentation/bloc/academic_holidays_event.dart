import 'package:equatable/equatable.dart';
import 'package:staff_app/features/academic_holidays/domain/entities/academic_holiday.dart';

abstract class AcademicHolidaysEvent extends Equatable {
  const AcademicHolidaysEvent();

  @override
  List<Object?> get props => [];
}

class LoadHolidaysEvent extends AcademicHolidaysEvent {
  const LoadHolidaysEvent({this.academicYearId});

  final String? academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

class FilterCategoryEvent extends AcademicHolidaysEvent {
  const FilterCategoryEvent(this.category);

  final String category; // 'ALL' | 'RELIGIOUS' | 'NATIONAL' | 'INSTITUTIONAL'

  @override
  List<Object?> get props => [category];
}

class SearchQueryChangedEvent extends AcademicHolidaysEvent {
  const SearchQueryChangedEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class CreateHolidayEvent extends AcademicHolidaysEvent {
  const CreateHolidayEvent(this.holiday);

  final AcademicHoliday holiday;

  @override
  List<Object?> get props => [holiday];
}

class UpdateHolidayEvent extends AcademicHolidaysEvent {
  const UpdateHolidayEvent({required this.id, required this.holiday});

  final String id;
  final AcademicHoliday holiday;

  @override
  List<Object?> get props => [id, holiday];
}

class DeleteHolidayEvent extends AcademicHolidaysEvent {
  const DeleteHolidayEvent({required this.id, required this.pin});

  final String id;
  final String pin;

  @override
  List<Object?> get props => [id, pin];
}
