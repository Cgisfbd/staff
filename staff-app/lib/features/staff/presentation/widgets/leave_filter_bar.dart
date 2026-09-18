import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/staff_leave_entity.dart';

/// Search input and status filter chips bar for Staff Leaves Hub.
class LeaveFilterBar extends StatelessWidget {
  const LeaveFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final StaffLeaveStatus? selectedStatus;
  final ValueChanged<StaffLeaveStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? 0.38 : 0.82),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.goldPrimary.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                // 1. Search TextField
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.28 : 0.65),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by faculty name, ID or reason...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.goldDark),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 14),
                              onPressed: () {
                                searchController.clear();
                                onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Filter Status Pills Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildPill(
                        context,
                        isDark: isDark,
                        label: 'All Requests',
                        isSelected: selectedStatus == null,
                        onTap: () => onStatusSelected(null),
                        accentColor: AppColors.goldPrimary,
                      ),
                      const SizedBox(width: 6),
                      _buildPill(
                        context,
                        isDark: isDark,
                        label: 'Pending',
                        isSelected: selectedStatus == StaffLeaveStatus.pending,
                        onTap: () => onStatusSelected(StaffLeaveStatus.pending),
                        accentColor: const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 6),
                      _buildPill(
                        context,
                        isDark: isDark,
                        label: 'Approved',
                        isSelected: selectedStatus == StaffLeaveStatus.approved,
                        onTap: () => onStatusSelected(StaffLeaveStatus.approved),
                        accentColor: const Color(0xFF059669),
                      ),
                      const SizedBox(width: 6),
                      _buildPill(
                        context,
                        isDark: isDark,
                        label: 'Rejected',
                        isSelected: selectedStatus == StaffLeaveStatus.rejected,
                        onTap: () => onStatusSelected(StaffLeaveStatus.rejected),
                        accentColor: const Color(0xFFE11D48),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required bool isDark,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor
              : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white12 : Colors.black12),
            width: 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
          ),
        ),
      ),
    );
  }
}
