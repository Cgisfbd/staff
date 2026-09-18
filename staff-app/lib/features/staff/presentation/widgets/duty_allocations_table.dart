import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';

/// Ultra-Clean Liquid Crystal Glass Duty Roster List for Faculty.
/// Displays only: Staff ID, Profile Avatar, Full Name, Class Count, Book Count,
/// and a single "Assign ➔" action button, keeping the interface minimal and elegant.
class DutyAllocationsTable extends StatelessWidget {
  const DutyAllocationsTable({
    super.key,
    required this.duties,
    required this.onAssignTap,
  });

  final List<StaffDutyEntity> duties;
  final ValueChanged<StaffDutyEntity> onAssignTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (duties.isEmpty) {
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
                  Icons.person_search_rounded,
                  size: 38,
                  color: isDark
                      ? AppColors.goldChampagne.withValues(alpha: 0.3)
                      : AppColors.goldDark.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  'No faculty records matching duty filters.',
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
                      const Icon(Icons.assignment_ind_rounded, size: 15, color: AppColors.goldDark),
                      const SizedBox(width: 8),
                      Text(
                        'FACULTY DUTY ROSTER',
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
                          '${duties.length} Teachers',
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

                // 2. Simple Minimalist Data Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: duties.length,
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
                    final duty = duties[index];
                    return _buildSimpleRow(duty, isDark: isDark);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleRow(StaffDutyEntity duty, {required bool isDark}) {
    final classCount = duty.assignedClasses.length;
    final bookCount = duty.assignedBooks.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAssignTap(duty),
        hoverColor: AppColors.goldPrimary.withValues(alpha: 0.04),
        splashColor: AppColors.goldPrimary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
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
                  duty.staffCode.toString(),
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
                backgroundImage: duty.avatar.isNotEmpty ? NetworkImage(duty.avatar) : null,
                child: duty.avatar.isEmpty
                    ? Text(
                        duty.fullNameEn.isNotEmpty ? duty.fullNameEn[0].toUpperCase() : 'F',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldDark,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // 3. Faculty Name + Count Badges (Classes Count & Books Count)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      duty.fullNameEn,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Class Count Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: classCount > 0
                                ? const Color(0xFF0284C7).withValues(alpha: 0.12)
                                : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: classCount > 0
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 10,
                                color: classCount > 0
                                    ? const Color(0xFF0284C7)
                                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$classCount ${classCount == 1 ? 'Class' : 'Classes'}',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: classCount > 0
                                      ? const Color(0xFF0284C7)
                                      : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Books Count Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: bookCount > 0
                                ? const Color(0xFFD97706).withValues(alpha: 0.12)
                                : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: bookCount > 0
                                  ? const Color(0xFFD97706).withValues(alpha: 0.3)
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 10,
                                color: bookCount > 0
                                    ? const Color(0xFFD97706)
                                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$bookCount ${bookCount == 1 ? 'Book' : 'Books'}',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: bookCount > 0
                                      ? const Color(0xFFD97706)
                                      : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 4. Single Action Button: Assign
              InkWell(
                onTap: () => onAssignTap(duty),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Assign',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded, size: 11, color: Colors.white),
                    ],
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
