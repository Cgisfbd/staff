import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class DutySearchBar extends StatelessWidget {
  const DutySearchBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  static const List<String> statusFilters = ['All', 'Configured', 'Pending'];

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
                  .withValues(alpha: isDark ? 0.38 : 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.75),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: isDark ? 0.28 : 0.65),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.3 : 0.25),
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 9),
                      Icon(
                        Icons.search_rounded,
                        size: 17,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by Teacher, ID, Class, Kitab...',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 9),
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 15),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Status Chips
                Row(
                  children: [
                    Text(
                      'STATUS:',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...statusFilters.map((s) {
                      final isSelected = selectedStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => onStatusSelected(s),
                          borderRadius: BorderRadius.circular(6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (s == 'Configured'
                                      ? const Color(0xFF059669)
                                      : s == 'Pending'
                                          ? const Color(0xFFD97706)
                                          : AppColors.goldPrimary)
                                  : (isDark ? const Color(0x1F0F172A) : const Color(0x52F8FAFC)),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark ? Colors.white12 : Colors.black12),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
