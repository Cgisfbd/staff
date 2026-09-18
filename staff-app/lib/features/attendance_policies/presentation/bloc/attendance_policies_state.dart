import 'package:equatable/equatable.dart';
import 'package:staff_app/features/attendance_policies/domain/entities/attendance_policy.dart';

enum AttendancePoliciesStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class AttendancePoliciesState extends Equatable {
  const AttendancePoliciesState({
    required this.status,
    required this.policy,
    required this.academicYearId,
    this.academicYearName,
    this.isModified = false,
    this.errorMessage,
    this.successMessage,
  });

  factory AttendancePoliciesState.initial() {
    return AttendancePoliciesState(
      status: AttendancePoliciesStatus.initial,
      policy: AttendancePolicy.defaultPolicy(''),
      academicYearId: '',
    );
  }

  final AttendancePoliciesStatus status;
  final AttendancePolicy policy;
  final String academicYearId;
  final String? academicYearName;
  final bool isModified;
  final String? errorMessage;
  final String? successMessage;

  String get weeklyOffShort {
    switch (policy.weeklyOffDay.toUpperCase()) {
      case 'MONDAY':
        return 'Mon';
      case 'TUESDAY':
        return 'Tue';
      case 'WEDNESDAY':
        return 'Wed';
      case 'THURSDAY':
        return 'Thu';
      case 'FRIDAY':
        return 'Fri';
      case 'SATURDAY':
        return 'Sat';
      case 'SUNDAY':
        return 'Sun';
      default:
        return policy.weeklyOffDay;
    }
  }

  AttendancePoliciesState copyWith({
    AttendancePoliciesStatus? status,
    AttendancePolicy? policy,
    String? academicYearId,
    String? academicYearName,
    bool? isModified,
    String? errorMessage,
    String? successMessage,
  }) {
    return AttendancePoliciesState(
      status: status ?? this.status,
      policy: policy ?? this.policy,
      academicYearId: academicYearId ?? this.academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      isModified: isModified ?? this.isModified,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        policy,
        academicYearId,
        academicYearName,
        isModified,
        errorMessage,
        successMessage,
      ];
}
