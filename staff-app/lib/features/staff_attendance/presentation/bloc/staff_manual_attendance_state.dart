import 'package:equatable/equatable.dart';
import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';

enum StaffAttendanceStateStatus {
  initial,
  loading,
  loaded,
  saving,
  success,
  failure,
}

class StaffManualAttendanceState extends Equatable {
  const StaffManualAttendanceState({
    this.status = StaffAttendanceStateStatus.initial,
    required this.selectedDate,
    this.records = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  final StaffAttendanceStateStatus status;
  final DateTime selectedDate;
  final List<StaffManualAttendanceEntity> records;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  bool get isLoading => status == StaffAttendanceStateStatus.loading;
  bool get isSaving => status == StaffAttendanceStateStatus.saving;

  List<StaffManualAttendanceEntity> get filteredRecords {
    if (searchQuery.trim().isEmpty) return records;
    final q = searchQuery.toLowerCase().trim();
    return records.where((r) {
      return r.fullNameEn.toLowerCase().contains(q) ||
          r.nameUrdu.toLowerCase().contains(q) ||
          r.staffCode.toString().contains(q) ||
          r.designation.toLowerCase().contains(q);
    }).toList();
  }

  int get totalCount => records.length;
  int get presentCount => records.where((r) => r.isPresent).length;
  int get absentCount => records.where((r) => r.isAbsent).length;
  int get leaveCount => records.where((r) => r.isLeave).length;
  int get punchedInCount => records.where((r) => r.isPunchedIn).length;
  int get punchedOutCount => records.where((r) => r.isPunchedOut).length;

  StaffManualAttendanceState copyWith({
    StaffAttendanceStateStatus? status,
    DateTime? selectedDate,
    List<StaffManualAttendanceEntity>? records,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return StaffManualAttendanceState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedDate,
        records,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}
