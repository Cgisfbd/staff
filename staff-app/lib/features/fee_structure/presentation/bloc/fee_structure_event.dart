import 'package:equatable/equatable.dart';

abstract class FeeStructureEvent extends Equatable {
  const FeeStructureEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeeStructuresEvent extends FeeStructureEvent {
  const LoadFeeStructuresEvent({this.courseId});

  final String? courseId;

  @override
  List<Object?> get props => [courseId];
}

class FilterFeeStructuresByCourseEvent extends FeeStructureEvent {
  const FilterFeeStructuresByCourseEvent(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class SearchFeeStructuresEvent extends FeeStructureEvent {
  const SearchFeeStructuresEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SaveFeeStructureEvent extends FeeStructureEvent {
  const SaveFeeStructureEvent({
    required this.classId,
    required this.className,
    this.id,
    this.tuitionFee,
    this.hostelFee,
    this.admissionFeeHostel,
    this.admissionFeeNonHostel,
    this.admissionRenewalFee,
    this.examFee,
    this.onlineFee,
    this.onlineAdmissionFee,
  });

  final String classId;
  final String className;
  final String? id;
  final int? tuitionFee;
  final int? hostelFee;
  final int? admissionFeeHostel;
  final int? admissionFeeNonHostel;
  final int? admissionRenewalFee;
  final int? examFee;
  final int? onlineFee;
  final int? onlineAdmissionFee;

  @override
  List<Object?> get props => [
        classId,
        className,
        id,
        tuitionFee,
        hostelFee,
        admissionFeeHostel,
        admissionFeeNonHostel,
        admissionRenewalFee,
        examFee,
        onlineFee,
        onlineAdmissionFee,
      ];
}

class DeleteFeeStructureEvent extends FeeStructureEvent {
  const DeleteFeeStructureEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
