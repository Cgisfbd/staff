import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';
import 'package:staff_app/features/staff/presentation/bloc/staff_leave_bloc.dart';
import 'package:staff_app/features/staff/presentation/widgets/leave_filter_bar.dart';
import 'package:staff_app/features/staff/presentation/widgets/leave_roster_table.dart';
import 'package:staff_app/features/staff/presentation/widgets/leave_summary_deck.dart';

/// Master Executive Hub for Staff Leave Requests & Approvals.
/// Focuses purely on Leave Approvals, Tracking & Rejections with zero clutter.
class StaffLeavesPage extends StatefulWidget {
  const StaffLeavesPage({super.key});

  @override
  State<StaffLeavesPage> createState() => _StaffLeavesPageState();
}

class _StaffLeavesPageState extends State<StaffLeavesPage> {
  late final StaffLeaveBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<StaffLeaveBloc>()..add(const LoadStaffLeavesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  /// Ultra-Luxury Rejection Dialog with Preset Reasons & Custom Note
  void _promptRejectDialog(StaffLeaveEntity leave) {
    final reasonCtrl = TextEditingController();
    final dateFormat = DateFormat('dd MMM');

    // Preset standard institutional reasons
    final presetReasons = [
      'Critical Exam Duty',
      'Shortage of Faculty Staff',
      'Urgent Class Revision Period',
      'Prior 48h Notice Required',
      'Syllabus Incomplete',
    ];

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF0F172A) : Colors.white)
                          .withValues(alpha: isDark ? 0.94 : 0.97),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Icon & Header Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.event_busy_rounded,
                                  color: Color(0xFFE11D48),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Reject Leave Request',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFE11D48),
                                      ),
                                    ),
                                    Text(
                                      'Provide official rejection remarks',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 2. Faculty Summary Tag Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black12,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                                  backgroundImage: leave.avatar.isNotEmpty ? NetworkImage(leave.avatar) : null,
                                  child: leave.avatar.isEmpty
                                      ? Text(leave.teacherName[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        leave.teacherName,
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '#${leave.staffCode} • ${leave.totalDays} Days (${dateFormat.format(leave.startDate)} – ${dateFormat.format(leave.endDate)})',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3. Quick Preset Reasons Chips
                          Text(
                            'QUICK PRESET REASONS (آسان وجوہات):',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: presetReasons.map((preset) {
                              final isSelected = reasonCtrl.text == preset;
                              return InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    reasonCtrl.text = preset;
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE11D48).withValues(alpha: 0.2)
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE11D48)
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    preset,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFFE11D48)
                                          : (isDark ? Colors.white70 : Colors.black87),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          // 4. Detailed Reason Input Box
                          Text(
                            'SPECIFIC REMARKS / REASON (وجۂ نامنظوری):',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: TextField(
                              controller: reasonCtrl,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 11.5),
                              decoration: InputDecoration(
                                hintText: 'Explain why this leave request cannot be approved...',
                                hintStyle: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                                contentPadding: const EdgeInsets.all(10),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 5. Action Buttons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  final note = reasonCtrl.text.trim();
                                  Navigator.pop(ctx);
                                  _bloc.add(RejectStaffLeaveEvent(
                                    leaveId: leave.id,
                                    rejectionReason: note.isNotEmpty ? note : 'Administrative disapproval.',
                                  ));
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.close_rounded, size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Confirm Rejection',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLeaveDetailsSheet(StaffLeaveEntity leave) {
    final dateFormat = DateFormat('dd MMM yyyy');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                    backgroundImage: leave.avatar.isNotEmpty ? NetworkImage(leave.avatar) : null,
                    child: leave.avatar.isEmpty
                        ? Text(leave.teacherName[0], style: const TextStyle(fontWeight: FontWeight.w900))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.teacherName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '#${leave.staffCode} • ${leave.designation}',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _buildDetailItem('Leave Nature', leave.leaveType.label),
              _buildDetailItem(
                'Duration',
                '${dateFormat.format(leave.startDate)} – ${dateFormat.format(leave.endDate)} (${leave.totalDays} Days)',
              ),
              _buildDetailItem('Reason', leave.reason),
              _buildDetailItem('Status', leave.status.name.toUpperCase()),
              if (leave.reviewedBy.isNotEmpty)
                _buildDetailItem('Reviewed By', leave.reviewedBy),
              if (leave.rejectionReason.isNotEmpty)
                _buildDetailItem('Rejection Note', leave.rejectionReason),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldDark),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                // 1. Executive Top Header (No Apply Leave button)
                ExecutiveTopHeader(
                  icon: Icons.event_available_rounded,
                  title: 'Staff Leave Requests',
                  subtitle: 'Review & approve faculty absence',
                  onIconTap: () => Navigator.of(context).maybePop(),
                ),

                // 2. Main Scrollable Roster
                Expanded(
                  child: BlocConsumer<StaffLeaveBloc, StaffLeaveState>(
                    listener: (context, state) {
                      if (state is StaffLeaveLoaded && state.actionSuccessMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.actionSuccessMessage!,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is StaffLeaveLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                          ),
                        );
                      }

                      if (state is StaffLeaveError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.statusAbsent),
                              const SizedBox(height: 10),
                              Text(state.message, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _bloc.add(const RefreshStaffLeavesEvent()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is StaffLeaveLoaded) {
                        return RefreshIndicator(
                          color: AppColors.goldPrimary,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          onRefresh: () async {
                            _bloc.add(const RefreshStaffLeavesEvent());
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.only(top: 8, bottom: 32),
                            children: [
                              // KPI Summary Deck
                              LeaveSummaryDeck(stats: state.stats),
                              const SizedBox(height: 12),

                              // Search & Status Filters Bar
                              LeaveFilterBar(
                                searchController: _searchController,
                                onSearchChanged: (q) => _bloc.add(SearchStaffLeavesEvent(q)),
                                selectedStatus: state.selectedStatus,
                                onStatusSelected: (s) => _bloc.add(FilterStaffLeavesEvent(status: s)),
                              ),
                              const SizedBox(height: 12),

                              // Leave Roster Table
                              LeaveRosterTable(
                                leaves: state.filteredLeaves,
                                processingId: state.isProcessingId,
                                onApprove: (leave) => _bloc.add(ApproveStaffLeaveEvent(leave.id)),
                                onReject: _promptRejectDialog,
                                onLeaveTap: _showLeaveDetailsSheet,
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
