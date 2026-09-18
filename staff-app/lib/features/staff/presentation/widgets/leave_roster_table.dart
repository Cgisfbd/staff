import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

/// Ultra-Clean Liquid Crystal Glass Leave Requests Roster.
/// Follows Zero Truncation Law for names, clean ID badges, date pill,
/// leave nature tag, status badge, and instant Approve / Reject actions.
class LeaveRosterTable extends StatelessWidget {
  const LeaveRosterTable({
    super.key,
    required this.leaves,
    required this.onApprove,
    required this.onReject,
    required this.onLeaveTap,
    this.processingId,
  });

  final List<StaffLeaveEntity> leaves;
  final ValueChanged<StaffLeaveEntity> onApprove;
  final ValueChanged<StaffLeaveEntity> onReject;
  final ValueChanged<StaffLeaveEntity> onLeaveTap;
  final String? processingId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (leaves.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x331E293B)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppColors.goldPrimary.withValues(alpha: 0.28),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 38,
                  color: isDark
                      ? AppColors.goldChampagne.withValues(alpha: 0.3)
                      : AppColors.goldDark.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  'No leave requests matching filter.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x331E293B)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : AppColors.goldPrimary.withValues(alpha: 0.28),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. Sleek Top Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.goldPrimary.withValues(alpha: 0.2)
                            : AppColors.goldPrimary.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_rounded, size: 15, color: AppColors.goldDark),
                      const SizedBox(width: 8),
                      Text(
                        'FACULTY LEAVE REQUESTS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${leaves.length} Records',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Continuous Clean Roster Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaves.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.7,
                    indent: 54,
                    endIndent: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  itemBuilder: (context, index) {
                    final leave = leaves[index];
                    final isProcessing = processingId == leave.id;
                    return _buildLeaveRow(context, leave, isDark: isDark, isProcessing: isProcessing);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRow(
    BuildContext context,
    StaffLeaveEntity leave, {
    required bool isDark,
    required bool isProcessing,
  }) {
    final dateFormat = DateFormat('dd MMM');
    final startStr = dateFormat.format(leave.startDate);
    final endStr = dateFormat.format(leave.endDate);
    final dateRangeStr = leave.totalDays == 1 ? startStr : '$startStr – $endStr';

    final isPending = leave.status == StaffLeaveStatus.pending;
    final isApproved = leave.status == StaffLeaveStatus.approved;

    final Color statusColor = isApproved
        ? const Color(0xFF059669)
        : (isPending ? const Color(0xFFD97706) : const Color(0xFFE11D48));

    final String statusLabel = isApproved
        ? 'APPROVED'
        : (isPending ? 'PENDING' : 'REJECTED');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onLeaveTap(leave),
        hoverColor: AppColors.goldPrimary.withValues(alpha: 0.04),
        splashColor: AppColors.goldPrimary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Staff ID Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  leave.staffCode.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: AppColors.goldDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Profile Photo (Avatar)
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.18),
                backgroundImage: leave.avatar.isNotEmpty ? NetworkImage(leave.avatar) : null,
                child: leave.avatar.isEmpty
                    ? Text(
                        leave.teacherName.isNotEmpty ? leave.teacherName[0].toUpperCase() : 'F',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldDark,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // 3. Teacher Name + Leave Details (Zero Truncation)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      leave.teacherName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 5,
                      runSpacing: 3,
                      children: [
                        // Date & Days Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 9.5, color: Color(0xFF0284C7)),
                              const SizedBox(width: 3),
                              Text(
                                '$dateRangeStr (${leave.totalDays}d)',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Leave Type Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            leave.leaveType.shortLabel,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 4. Status Badge or Action Controls
              if (isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isProcessing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldPrimary),
                      )
                    else ...[
                      // Quick Approve Button (Green Check)
                      InkWell(
                        onTap: () => onApprove(leave),
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: const Color(0xFF059669).withValues(alpha: 0.4),
                              width: 0.9,
                            ),
                          ),
                          child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF059669)),
                        ),
                      ),
                      const SizedBox(width: 5),

                      // Quick Reject Button (Red Cross)
                      InkWell(
                        onTap: () => onReject(leave),
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                              width: 0.9,
                            ),
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFE11D48)),
                        ),
                      ),
                    ],
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
