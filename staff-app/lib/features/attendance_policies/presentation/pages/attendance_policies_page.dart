import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_bloc.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_event.dart';
import 'package:staff_app/features/attendance_policies/presentation/bloc/attendance_policies_state.dart';
import 'package:staff_app/features/attendance_policies/presentation/widgets/policies_bottom_actions.dart';
import 'package:staff_app/features/attendance_policies/presentation/widgets/policy_card_auto_dropout.dart';
import 'package:staff_app/features/attendance_policies/presentation/widgets/policy_card_minimum_attendance.dart';
import 'package:staff_app/features/attendance_policies/presentation/widgets/policy_card_staff_leave.dart';
import 'package:staff_app/features/attendance_policies/presentation/widgets/policy_card_student_leave.dart';
import 'package:staff_app/features/attendance_policies/presentation/widgets/weekly_off_day_selector.dart';

class AttendancePoliciesPage extends StatelessWidget {
  const AttendancePoliciesPage({super.key, this.academicYearId});

  final String? academicYearId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AttendancePoliciesBloc>(
      create: (_) => sl<AttendancePoliciesBloc>()
        ..add(LoadAttendancePoliciesEvent(academicYearId: academicYearId)),
      child: const _AttendancePoliciesView(),
    );
  }
}

class _AttendancePoliciesView extends StatelessWidget {
  const _AttendancePoliciesView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendancePoliciesBloc, AttendancePoliciesState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.successMessage != current.successMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == AttendancePoliciesStatus.saved && state.successMessage != null) {
          AppSnackBar.showSuccess(context, state.successMessage!);
        } else if (state.status == AttendancePoliciesStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: AppBackground(
            useSafeArea: false,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExecutiveTopHeader(
                    icon: Icons.arrow_back_rounded,
                    title: 'Rules & Policies',
                    subtitle: state.academicYearName ?? 'Session rules, quotas & weekly off',
                    onIconTap: () => Navigator.of(context).pop(),
                  ),

                  // Main Scrollable Form Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekly Off Day Setup Card
                          WeeklyOffDaySelector(
                            selectedDay: state.policy.weeklyOffDay,
                            onSelectDay: (day) => context
                                .read<AttendancePoliciesBloc>()
                                .add(UpdateWeeklyOffDayEvent(day)),
                          ),

                          const SizedBox(height: 12),

                          // Card 1: Minimum Attendance
                          PolicyCardMinimumAttendance(
                            percent: state.policy.minimumAttendancePercent,
                            onChanged: (pct) => context
                                .read<AttendancePoliciesBloc>()
                                .add(UpdateMinimumAttendanceEvent(pct)),
                          ),

                          const SizedBox(height: 12),

                          // Card 2: Student Annual Leave Quota
                          PolicyCardStudentLeave(
                            quotaDays: state.policy.annualStudentLeaveQuota,
                            onChanged: (days) => context
                                .read<AttendancePoliciesBloc>()
                                .add(UpdateStudentLeaveQuotaEvent(days)),
                          ),

                          const SizedBox(height: 12),

                          // Card 3: Staff Annual Leave Quota
                          PolicyCardStaffLeave(
                            quotaDays: state.policy.annualStaffLeaveQuota,
                            onChanged: (days) => context
                                .read<AttendancePoliciesBloc>()
                                .add(UpdateStaffLeaveQuotaEvent(days)),
                          ),

                          const SizedBox(height: 12),

                          // Card 4: Auto-Dropout Trigger
                          PolicyCardAutoDropout(
                            dropoutDays: state.policy.consecutiveAbsentDropoutDays,
                            onChanged: (days) => context
                                .read<AttendancePoliciesBloc>()
                                .add(UpdateConsecutiveDropoutDaysEvent(days)),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Fixed Action Bar
                  PoliciesBottomActions(
                    status: state.status,
                    onResetDefaults: () => context
                        .read<AttendancePoliciesBloc>()
                        .add(const ResetPoliciesToDefaultEvent()),
                    onSave: () => context
                        .read<AttendancePoliciesBloc>()
                        .add(const SaveAttendancePoliciesEvent()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
