import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/features/staff_attendance/domain/entities/staff_manual_attendance_entity.dart';

/// Luxury Liquid Crystal Card for Staff Manual Attendance & Punch In/Out (< 260 lines).
class StaffManualAttendanceItemCard extends StatelessWidget {
  const StaffManualAttendanceItemCard({
    super.key,
    required this.record,
    required this.onStatusChanged,
    required this.onPunchInChanged,
    required this.onPunchOutChanged,
  });

  final StaffManualAttendanceEntity record;
  final ValueChanged<StaffAttendanceStatus> onStatusChanged;
  final void Function(String? punchInTime, bool clear) onPunchInChanged;
  final void Function(String? punchOutTime, bool clear) onPunchOutChanged;

  String _formatCurrentTime() {
    return AppFormatters.formatTime(DateTime.now());
  }

  Future<void> _selectCustomTime(
    BuildContext context, {
    required bool isPunchIn,
  }) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked != null && context.mounted) {
      final nowDt = DateTime.now();
      final dt = DateTime(nowDt.year, nowDt.month, nowDt.day, picked.hour, picked.minute);
      final formatted = AppFormatters.formatTime(dt);

      if (isPunchIn) {
        onPunchInChanged(formatted, false);
      } else {
        onPunchOutChanged(formatted, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x331E293B)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : const Color(0x99FFFFFF),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Staff Info & Status Row
                Row(
                  children: [
                    // Staff Avatar Circle
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldPrimary.withValues(alpha: 0.3),
                            AppColors.goldPrimary.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        record.fullNameEn.isNotEmpty ? record.fullNameEn[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Staff Name & Code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.fullNameEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#${record.staffCode}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.goldPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  record.designation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Direct P / A / L Segment Selector
                    _buildStatusPills(isDark),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  thickness: 0.7,
                  color: isDark ? const Color(0x26FFFFFF) : const Color(0x1F000000),
                ),
                const SizedBox(height: 10),

                // 2. Punch In & Punch Out Action Controls
                Row(
                  children: [
                    // Punch In
                    Expanded(
                      child: _buildPunchInButton(context, isDark),
                    ),
                    const SizedBox(width: 8),

                    // Punch Out
                    Expanded(
                      child: _buildPunchOutButton(context, isDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPills(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0x33000000) : const Color(0x12000000),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillItem(
            label: 'P',
            isSelected: record.isPresent,
            activeColor: const Color(0xFF10B981),
            onTap: () {
              HapticFeedback.lightImpact();
              onStatusChanged(StaffAttendanceStatus.present);
            },
          ),
          _buildPillItem(
            label: 'A',
            isSelected: record.isAbsent,
            activeColor: const Color(0xFFEF4444),
            onTap: () {
              HapticFeedback.lightImpact();
              onStatusChanged(StaffAttendanceStatus.absent);
            },
          ),
          _buildPillItem(
            label: 'L',
            isSelected: record.isLeave,
            activeColor: const Color(0xFFF59E0B),
            onTap: () {
              HapticFeedback.lightImpact();
              onStatusChanged(StaffAttendanceStatus.leave);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillItem({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildPunchInButton(BuildContext context, bool isDark) {
    if (record.isPunchedIn) {
      return InkWell(
        onTap: () => _selectCustomTime(context, isPunchIn: true),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onPunchInChanged(null, true);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x1F10B981),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x8010B981),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  context.tr('staff_att_in_prefix', params: {'time': record.punchInTime!}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPunchInChanged(null, true);
                },
                child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPunchInChanged(_formatCurrentTime(), false);
      },
      onLongPress: () => _selectCustomTime(context, isPunchIn: true),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x1FFFFFFF) : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0x33FFFFFF) : const Color(0x26000000),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login_rounded,
              size: 13,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                context.tr('staff_att_punch_in'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunchOutButton(BuildContext context, bool isDark) {
    if (record.isPunchedOut) {
      return InkWell(
        onTap: () => _selectCustomTime(context, isPunchIn: false),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onPunchOutChanged(null, true);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0x1F6366F1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x806366F1),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, size: 14, color: Color(0xFF6366F1)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  context.tr('staff_att_out_prefix', params: {'time': record.punchOutTime!}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPunchOutChanged(null, true);
                },
                child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF6366F1)),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPunchOutChanged(_formatCurrentTime(), false);
      },
      onLongPress: () => _selectCustomTime(context, isPunchIn: false),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x1FFFFFFF) : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0x33FFFFFF) : const Color(0x26000000),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 13,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                context.tr('staff_att_punch_out'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
