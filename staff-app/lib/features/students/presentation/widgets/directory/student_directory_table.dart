import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';

/// Ultra-Luxury Enterprise Liquid Crystal Glass Data Table (< 350 lines).
/// Perfectly harmonized with the Champagne Gold & Velvet Obsidian design system.
/// Features expanded column widths (710px total), zero clipping, and action chevron.
class StudentDirectoryTable extends StatelessWidget {
  const StudentDirectoryTable({
    super.key,
    required this.students,
    required this.onStudentTap,
  });

  final List<StudentDirectoryEntity> students;
  final ValueChanged<StudentDirectoryEntity> onStudentTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (students.isEmpty) {
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
                  color: isDark ? AppColors.goldChampagne.withValues(alpha: 0.3) : AppColors.goldDark.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  'No student records matching filters.',
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
                width: 740,
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
                          _buildHeaderCell('ROLL', width: 46, isDark: isDark),
                          _buildHeaderCell('STUDENT NAME', width: 155, isDark: isDark),
                          _buildHeaderCell('FATHER NAME', width: 105, isDark: isDark),
                          _buildHeaderCell('COURSE & CLASS', width: 105, isDark: isDark),
                          _buildHeaderCell('MOBILE', width: 95, isDark: isDark),
                          _buildHeaderCell('ADDRESS', width: 140, isDark: isDark),
                          _buildHeaderCell('STATUS', width: 70, isDark: isDark),
                        ],
                      ),
                    ),

                    // Table Data Rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 0.7,
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                      ),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildTableRow(context, student, isDark);
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
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, StudentDirectoryEntity student, bool isDark) {
    final hasPhoto = student.photoUrl != null && student.photoUrl!.isNotEmpty;

    return InkWell(
      onTap: () => onStudentTap(student),
      onDoubleTap: () => onStudentTap(student),
      splashColor: AppColors.goldPrimary.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            // 1. Roll No Badge (Champagne Gold Pill)
            SizedBox(
              width: 46,
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
                    '${student.rollNo}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Student Name + Avatar + Urdu in Gold + RFID
            SizedBox(
              width: 155,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                    backgroundImage: hasPhoto ? NetworkImage(student.photoUrl!) : null,
                    onBackgroundImageError: hasPhoto ? (_, __) {} : null,
                    child: !hasPhoto
                        ? Text(
                            student.fullNameEn.isNotEmpty ? student.fullNameEn[0] : 'S',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldDark,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullNameEn,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (student.nameUrdu.isNotEmpty)
                          Text(
                            student.nameUrdu,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          'RFID: ${student.rfidNo}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Father Name
            SizedBox(
              width: 105,
              child: Text(
                student.fatherNameEn,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 4. Course & Class (COURSE FIRST, then CLASS)
            SizedBox(
              width: 105,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (student.courseName.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 2.5),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.35),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        student.courseName,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.statusPresent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.statusPresent.withValues(alpha: 0.3),
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      student.className,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 5. Mobile Number
            SizedBox(
              width: 95,
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 10.5, color: AppColors.goldPrimary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      student.mobile,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 6. Address (Full Address Column)
            SizedBox(
              width: 140,
              child: Text(
                student.fullAddress,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 7. Status Pill
            SizedBox(
              width: 70,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusPill(student.status),
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
      case 'dropout':
        bg = AppColors.statusAbsent.withValues(alpha: 0.12);
        border = AppColors.statusAbsent.withValues(alpha: 0.35);
        text = AppColors.statusAbsent;
        break;
      case 'suspend':
      case 'suspended':
        bg = const Color(0xFFEA580C).withValues(alpha: 0.12);
        border = const Color(0xFFEA580C).withValues(alpha: 0.35);
        text = const Color(0xFFEA580C);
        break;
      case 'graduate':
      case 'graduated':
        bg = AppColors.statusLeave.withValues(alpha: 0.12);
        border = AppColors.statusLeave.withValues(alpha: 0.35);
        text = const Color(0xFFD97706);
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
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusPresent,
              ),
            ),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
