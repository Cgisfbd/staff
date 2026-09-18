import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Interactive Search and Multi-Category Filter Bar for Faculty Directory.
/// 100% Harmonized with StudentSearchFilterBar with Liquid Crystal Glassmorphism,
/// unified search card, horizontal scrolling chips, and zero-overflow layout.
class StaffSearchFilterBar extends StatelessWidget {
  const StaffSearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.selectedDutyMode,
    required this.onDutyModeSelected,
    required this.selectedDesignation,
    required this.onDesignationSelected,
    this.totalMatches = 0,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;
  final String selectedDutyMode;
  final ValueChanged<String> onDutyModeSelected;
  final String selectedDesignation;
  final ValueChanged<String> onDesignationSelected;
  final int totalMatches;

  static const List<String> statusOptions = [
    'All',
    'Active',
    'On Leave',
    'Resigned',
  ];

  static const List<String> dutyModeOptions = [
    'All',
    'Hostel Resident',
    'Day Duty',
    'Online',
  ];

  static const List<String> designationOptions = [
    'All',
    'Principal',
    'Senior Ustad',
    'Head Qari',
    'Mudarris',
    'Accountant',
    'Clerk',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? 0.40 : 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.75),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search TextField with Icon & Clear Action (Matching Student Bar)
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: isDark ? 0.3 : 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldPrimary
                          .withValues(alpha: isDark ? 0.35 : 0.28),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.goldChampagne
                            : AppColors.goldDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search by Name, Staff ID, Mobile, Subject...',
                            hintStyle: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textDarkMuted
                                  : AppColors.textLightMuted,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32, minHeight: 32),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Status, Duty Mode & Role Filter Chips Row (Horizontal Scrollable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildHeaderLabel('STATUS:', isDark),
                      const SizedBox(width: 6),
                      ...statusOptions.map((status) => _buildChip(
                            label: status,
                            isSelected: selectedStatus == status,
                            onTap: () => onStatusSelected(status),
                            isDark: isDark,
                            activeColor: _statusColor(status),
                          )),
                      const SizedBox(width: 10),
                      Container(
                          width: 1,
                          height: 16,
                          color: isDark ? Colors.white24 : Colors.black12),
                      const SizedBox(width: 10),
                      _buildHeaderLabel('DUTY:', isDark),
                      const SizedBox(width: 6),
                      ...dutyModeOptions.map((mode) => _buildChip(
                            label: mode,
                            isSelected: selectedDutyMode == mode,
                            onTap: () => onDutyModeSelected(mode),
                            isDark: isDark,
                            activeColor: AppColors.goldPrimary,
                          )),
                      const SizedBox(width: 10),
                      Container(
                          width: 1,
                          height: 16,
                          color: isDark ? Colors.white24 : Colors.black12),
                      const SizedBox(width: 10),
                      _buildHeaderLabel('ROLE:', isDark),
                      const SizedBox(width: 6),
                      ...designationOptions.map((desig) => _buildChip(
                            label: desig,
                            isSelected: selectedDesignation == desig,
                            onTap: () => onDesignationSelected(desig),
                            isDark: isDark,
                            activeColor: const Color(0xFF059669),
                          )),
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

  Widget _buildHeaderLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white12 : Colors.black12),
              width: 0.9,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.statusPresent;
      case 'on leave':
      case 'leave':
        return const Color(0xFFD97706);
      case 'resigned':
      case 'terminated':
        return AppColors.statusAbsent;
      default:
        return AppColors.goldPrimary;
    }
  }
}
