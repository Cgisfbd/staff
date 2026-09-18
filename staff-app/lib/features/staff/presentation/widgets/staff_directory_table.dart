import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';

/// Ultra-Luxury Enterprise Liquid Crystal Glass Data Table for Faculty & Staff.
/// Perfectly harmonized with the Champagne Gold & Velvet Obsidian design system.
/// Features 950px horizontal scrolling table mirroring StudentDirectoryTable,
/// dedicated Department & Mobile columns, clean Staff ID badges (no # prefix),
/// multi-line text wrapping (no "..." ellipsis), and tap to open Faculty Dossier PDF.
class StaffDirectoryTable extends StatelessWidget {
  const StaffDirectoryTable({
    super.key,
    required this.teachers,
    required this.onTeacherTap,
    this.onEditTeacher,
  });

  final List<TeacherDirectoryEntity> teachers;
  final ValueChanged<TeacherDirectoryEntity> onTeacherTap;
  final ValueChanged<TeacherDirectoryEntity>? onEditTeacher;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (teachers.isEmpty) {
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
                  'No faculty records matching filters.',
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 1080,
                child: Column(
                  children: [
                    // Table Header Row (Champagne Gold tracking)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          _buildHeaderCell('STAFF ID', width: 50, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('FACULTY NAME', width: 190, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('FATHER NAME', width: 120, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('DEPARTMENT', width: 130, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('DESIGNATION', width: 120, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('MOBILE', width: 105, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('ADDRESS', width: 140, isDark: isDark),
                          const SizedBox(width: 16),
                          _buildHeaderCell('STATUS', width: 75, isDark: isDark),
                        ],
                      ),
                    ),

                    // Table Data Rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teachers.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 0.7,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      itemBuilder: (context, index) {
                        final teacher = teachers[index];
                        return _buildTableRow(context, teacher, isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    required double width,
    required bool isDark,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: alignment,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              fontSize: 9.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, TeacherDirectoryEntity teacher, bool isDark) {
    final hasPhoto = teacher.photoUrl != null && teacher.photoUrl!.isNotEmpty;

    return InkWell(
      onTap: () => onTeacherTap(teacher),
      onDoubleTap: () => onTeacherTap(teacher),
      splashColor: AppColors.goldPrimary.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Staff ID Badge (No '#' symbol, pure ID e.g. 101, 102)
            SizedBox(
              width: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${teacher.staffCode}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: AppColors.goldDark,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2. Faculty Name + Avatar (Matching Student Directory 1:1) + Urdu in Gold + RFID
            SizedBox(
              width: 190,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                    backgroundImage: hasPhoto ? NetworkImage(teacher.photoUrl!) : null,
                    onBackgroundImageError: hasPhoto ? (_, __) {} : null,
                    child: !hasPhoto
                        ? Text(
                            _getInitials(teacher.fullNameEn),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldDark,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          teacher.fullNameEn,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 2,
                          softWrap: true,
                        ),
                        if (teacher.nameUrdu.isNotEmpty)
                          Text(
                            teacher.nameUrdu,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                          ),
                        Text(
                          'RFID: ${teacher.rfidNo.isNotEmpty ? teacher.rfidNo : "STF-${teacher.staffCode}"}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 3. Father Name (No ellipsis, wraps cleanly)
            SizedBox(
              width: 120,
              child: Text(
                teacher.fatherNameEn.isNotEmpty ? teacher.fatherNameEn : '—',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ),
            const SizedBox(width: 16),

            // 4. Department Column (Dedicated, 130px, clean text, softWrap, no "...")
            SizedBox(
              width: 130,
              child: Text(
                teacher.department.isNotEmpty ? teacher.department : 'General Islamic',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ),
            const SizedBox(width: 16),

            // 5. Designation Column (Dedicated, 120px, clean text, softWrap, no "...")
            SizedBox(
              width: 120,
              child: Text(
                teacher.designation.isNotEmpty ? teacher.designation : 'Mudarris',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ),
            const SizedBox(width: 16),

            // 6. Mobile Column (Dedicated, phone icon + number, no "...")
            SizedBox(
              width: 105,
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 10.5, color: AppColors.goldPrimary),
                  const SizedBox(width: 3.5),
                  Expanded(
                    child: Text(
                      teacher.phone,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 7. Full Permanent Address (softWrap, maxLines 2)
            SizedBox(
              width: 140,
              child: Text(
                teacher.fullAddress.isNotEmpty ? teacher.fullAddress : 'Address not registered',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ),
            const SizedBox(width: 16),

            // 8. Status Pill with Glowing Pulse Dot
            SizedBox(
              width: 75,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusPill(teacher.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color border;
    Color text;
    bool hasPulse = false;

    switch (status.toLowerCase()) {
      case 'active':
        bg = AppColors.statusPresent.withValues(alpha: 0.12);
        border = AppColors.statusPresent.withValues(alpha: 0.35);
        text = const Color(0xFF059669);
        hasPulse = true;
        break;
      case 'on leave':
      case 'leave':
        bg = AppColors.statusLeave.withValues(alpha: 0.12);
        border = AppColors.statusLeave.withValues(alpha: 0.35);
        text = const Color(0xFFD97706);
        break;
      case 'resigned':
      case 'terminated':
      case 'inactive':
        bg = AppColors.statusAbsent.withValues(alpha: 0.12);
        border = AppColors.statusAbsent.withValues(alpha: 0.35);
        text = AppColors.statusAbsent;
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.12);
        border = Colors.grey.withValues(alpha: 0.35);
        text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPulse) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: text,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 3.5),
          ],
          Flexible(
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: text,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
            ),
          ),
        ],
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
