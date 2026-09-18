import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';

class DutyTeacherCard extends StatelessWidget {
  const DutyTeacherCard({
    super.key,
    required this.duty,
    required this.onTapAssign,
  });

  final StaffDutyEntity duty;
  final VoidCallback onTapAssign;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = duty.avatar.isNotEmpty;
    final hasClasses = duty.assignedClasses.isNotEmpty;
    final hasBooks = duty.assignedBooks.isNotEmpty;
    final isConfigured = hasClasses || hasBooks;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0x331E293B) : Colors.white)
                  .withValues(alpha: isDark ? 0.38 : 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.goldPrimary.withValues(alpha: 0.22),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Teacher Profile Header Row
                Row(
                  children: [
                    // Avatar with Gold Border
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                      backgroundImage: hasPhoto ? NetworkImage(duty.avatar) : null,
                      child: !hasPhoto
                          ? Text(
                              _getInitials(duty.fullNameEn),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldDark,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),

                    // Name + Designation + Urdu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  duty.fullNameEn,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Staff ID Pill (No '#' prefix)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                    width: 0.7,
                                  ),
                                ),
                                child: Text(
                                  '${duty.staffCode}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.goldDark,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  duty.designation.isNotEmpty ? duty.designation : 'Mudarris',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (duty.fullNameUr.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  duty.fullNameUr,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  maxLines: 1,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 2. Assigned Classes Chips Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'CLASSES:',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: hasClasses
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: duty.assignedClasses.map((cls) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFF059669).withValues(alpha: 0.3),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Text(
                                      cls,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Text(
                              'No classes assigned',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 3. Assigned Books Chips Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'KITABS:',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: hasBooks
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: duty.assignedBooks.map((bk) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.menu_book_rounded, size: 10, color: AppColors.goldDark),
                                        const SizedBox(width: 3.5),
                                        Text(
                                          bk.bookName,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.goldDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Text(
                              'No kitabs allocated',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Footer Row: Status + Assign Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isConfigured
                            ? const Color(0xFF059669).withValues(alpha: 0.12)
                            : const Color(0xFFD97706).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isConfigured
                              ? const Color(0xFF059669).withValues(alpha: 0.35)
                              : const Color(0xFFD97706).withValues(alpha: 0.35),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        isConfigured
                            ? '${duty.assignedClasses.length} Classes • ${duty.assignedBooks.length} Kitabs'
                            : 'Pending Allocation',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: isConfigured ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ),

                    // Primary Action Button
                    InkWell(
                      onTap: onTapAssign,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldPrimary, AppColors.goldDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withValues(alpha: 0.28),
                              blurRadius: 6,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Assign Classes & Books',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
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
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'ST';
  }
}
