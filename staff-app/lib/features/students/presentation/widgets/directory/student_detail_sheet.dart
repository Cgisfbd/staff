import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';

/// Modal Bottom Sheet displaying comprehensive student profile & bio mirroring ERP (< 250 lines).
class StudentDetailSheet extends StatelessWidget {
  const StudentDetailSheet({
    super.key,
    required this.student,
    this.onEdit,
    this.onPrintPdf,
  });

  final StudentDirectoryEntity student;
  final VoidCallback? onEdit;
  final VoidCallback? onPrintPdf;

  static void show(
    BuildContext context,
    StudentDirectoryEntity student, {
    VoidCallback? onEdit,
    VoidCallback? onPrintPdf,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentDetailSheet(
        student: student,
        onEdit: onEdit,
        onPrintPdf: onPrintPdf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xF00F172A) : Colors.white).withValues(alpha: isDark ? 0.92 : 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header: Photo + Names + Roll No
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.25),
                      backgroundImage: student.photoUrl != null && student.photoUrl!.isNotEmpty
                          ? NetworkImage(student.photoUrl!)
                          : null,
                      child: (student.photoUrl == null || student.photoUrl!.isEmpty)
                          ? Text(
                              student.fullNameEn.isNotEmpty ? student.fullNameEn[0] : 'S',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.goldDark,
                              ),
                            )
                        : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  student.fullNameEn,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${student.rollNo}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (student.nameUrdu.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              student.nameUrdu,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            'RFID: ${student.rfidNo} • ${student.status}',
                            style: TextStyle(
                              fontSize: 10.5,
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

              const SizedBox(height: 16),
              Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

              // Scrollable Details Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Section 1: Academic Info
                    _buildSectionHeader('ACADEMIC DETAILS', Icons.school_rounded, isDark),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      isDark,
                      [
                        _InfoItem('Department / Course', student.courseName.isNotEmpty ? student.courseName : 'General'),
                        _InfoItem('Class & Section', student.className),
                        _InfoItem('Study Mode', student.modeOfStudy),
                        _InfoItem('Hostel Facility', student.hostelFacility),
                        if (student.admissionDate.isNotEmpty)
                          _InfoItem('Admission Date', student.admissionDate),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Section 2: Parent & Guardian Details
                    _buildSectionHeader('PARENT & GUARDIAN', Icons.family_restroom_rounded, isDark),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      isDark,
                      [
                        _InfoItem('Father Name', student.fatherNameEn),
                        if (student.fatherNameUr.isNotEmpty)
                          _InfoItem('Father Name (Urdu)', student.fatherNameUr, isRtl: true),
                        if (student.fatherOccupation.isNotEmpty)
                          _InfoItem('Father Occupation', student.fatherOccupation),
                        if (student.motherNameEn.isNotEmpty)
                          _InfoItem('Mother Name', student.motherNameEn),
                        if (student.motherOccupation.isNotEmpty)
                          _InfoItem('Mother Occupation', student.motherOccupation),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Section 3: Contact & Address
                    _buildSectionHeader('CONTACT & RESIDENCE', Icons.home_rounded, isDark),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      isDark,
                      [
                        _InfoItem(
                          'Mobile Number',
                          student.mobile,
                          hasCopy: true,
                          onCopy: () {
                            Clipboard.setData(ClipboardData(text: student.mobile));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mobile number copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        if (student.altMobile.isNotEmpty)
                          _InfoItem('Alternate Mobile', student.altMobile),
                        _InfoItem('Full Address', student.fullAddress),
                        if (student.prevSchoolName.isNotEmpty)
                          _InfoItem('Previous Institute', student.prevSchoolName),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Luxury Frosted Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: isDark ? 0.85 : 0.95),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                      width: 0.9,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Edit Record Button
                      if (onEdit != null) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_note_rounded, size: 16),
                            label: const Text(
                              'Edit Record',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Print Slip Button
                      if (onPrintPdf != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onPrintPdf,
                            icon: const Icon(Icons.print_outlined, size: 16),
                            label: const Text(
                              'Print Slip',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Close Button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          foregroundColor: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
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

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.goldPrimary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark, List<_InfoItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.04 : 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.value,
                          textDirection: item.isRtl ? TextDirection.rtl : TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                      ),
                      if (item.hasCopy && item.onCopy != null) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: item.onCopy,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.copy_rounded, size: 12, color: AppColors.goldDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(
    this.label,
    this.value, {
    this.isRtl = false,
    this.hasCopy = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool isRtl;
  final bool hasCopy;
  final VoidCallback? onCopy;
}
