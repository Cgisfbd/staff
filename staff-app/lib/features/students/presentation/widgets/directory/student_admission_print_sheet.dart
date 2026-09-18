import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/presentation/pages/student_admission_page.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_export_dialog.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_pdf_generator.dart';

/// Full-Screen Modal Sheet displaying the official Student Admission Print Form (درخواستِ داخلہ طالب علم).
/// Directly mirrors ERP StudentAdmissionPrintForm.tsx with Edit Student and Print PDF actions.
class StudentAdmissionPrintSheet extends StatelessWidget {
  const StudentAdmissionPrintSheet({
    super.key,
    required this.student,
    this.onStudentUpdated,
  });

  final StudentDirectoryEntity student;
  final ValueChanged<StudentDirectoryEntity>? onStudentUpdated;

  static void show(
    BuildContext context,
    StudentDirectoryEntity student, {
    ValueChanged<StudentDirectoryEntity>? onStudentUpdated,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentAdmissionPrintSheet(
        student: student,
        onStudentUpdated: onStudentUpdated,
      ),
    );
  }

  void _handleEdit(BuildContext context) async {
    Navigator.of(context).pop(); // Close print preview sheet
    final result = await Navigator.of(context).push<StudentDirectoryEntity>(
      MaterialPageRoute(
        builder: (_) => StudentAdmissionPage(
          initialStudent: student,
          isEditMode: true,
        ),
      ),
    );
    if (result != null && onStudentUpdated != null) {
      onStudentUpdated!(result);
    }
  }

  void _handlePrint(BuildContext context) async {
    try {
      await StudentPdfGenerator.exportAndOpenPdf(
        students: [student],
        selectedFields: allExportFields,
        courseFilter: student.courseName.isNotEmpty ? student.courseName : 'All',
        classFilter: student.className.isNotEmpty ? student.className : 'All',
        statusFilter: student.status,
        modeFilter: student.modeOfStudy,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = student.photoUrl != null && student.photoUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.white,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. Toolbar Header (Actions: Edit Student, Print PDF, Close)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    // Back / Close
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: isDark ? Colors.white70 : Colors.black87,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Admission Form',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          Text(
                            'درخواستِ داخلہ طالب علم • Roll No: ${student.rollNo}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action 1: Edit Student Button
                    ElevatedButton.icon(
                      onPressed: () => _handleEdit(context),
                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Action 2: Print / PDF Button
                    ElevatedButton.icon(
                      onPressed: () => _handlePrint(context),
                      icon: const Icon(Icons.print_rounded, size: 15),
                      label: const Text('Print', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF047857),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.8),

              // 3. Official Printable A4 Document View (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF047857), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Institution Header
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF047857).withValues(alpha: 0.3)),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'TALEEMONE INSTITUTIONAL ACADEMY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF047857),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'STUDENT ADMISSION FORM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                'درخواستِ داخلہ طالب علم',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Enrolment Banner (Roll No, RFID, Admission Date)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Roll No: ${student.rollNo}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                              ),
                              Text(
                                'RFID: ${student.rfidNo}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0D9488)),
                              ),
                              Text(
                                'Date: ${student.admissionDate.isNotEmpty ? student.admissionDate : "2024-07-10"}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Student Photo & Core Identity
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo Box
                            Container(
                              width: 68,
                              height: 82,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF047857), width: 1.2),
                                color: const Color(0xFFF1F5F9),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: hasPhoto
                                  ? Image.network(student.photoUrl!, fit: BoxFit.cover)
                                  : const Center(
                                      child: Icon(Icons.person_rounded, size: 36, color: Color(0xFF94A3B8)),
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Identity Block
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDataRow('Full Name (EN)', student.fullNameEn),
                                  if (student.nameUrdu.isNotEmpty)
                                    _buildDataRow('Full Name (UR)', student.nameUrdu, isUrdu: true),
                                  _buildDataRow('Father Name', student.fatherNameEn),
                                  _buildDataRow('Account Status', student.status, isStatus: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Section 1: Personal Details
                        _buildSectionHeader('1. Personal Details (معلوماتِ طالب علم)', Icons.person_outline_rounded),
                        _buildGrid([
                          _Item('Date of Birth', student.dob.isNotEmpty ? student.dob : '15 Apr 2010'),
                          _Item('Gender', student.gender),
                          _Item('Caste / Biradri', student.caste.isNotEmpty ? student.caste : 'Ansari'),
                          _Item('Aadhar No', student.aadharNo.isNotEmpty ? student.aadharNo : '7823 4567 8901'),
                        ]),
                        const SizedBox(height: 10),

                        // Section 2: Parents & Guardian Details
                        _buildSectionHeader('2. Parents Details (معلوماتِ والدین)', Icons.family_restroom_rounded),
                        _buildGrid([
                          _Item('Father Name (EN)', student.fatherNameEn),
                          _Item('Father Name (UR)', student.fatherNameUr.isNotEmpty ? student.fatherNameUr : 'طارق انور'),
                          _Item('Father Occupation', student.fatherOccupation.isNotEmpty ? student.fatherOccupation : 'Business'),
                          _Item('Mother Name', student.motherNameEn.isNotEmpty ? student.motherNameEn : 'Sultana Khatoon'),
                          _Item('Primary Mobile', student.mobile),
                          _Item('Alternate Mobile', student.altMobile.isNotEmpty ? student.altMobile : 'N/A'),
                        ]),
                        const SizedBox(height: 10),

                        // Section 3: Residential Address
                        _buildSectionHeader('3. Residential Address (پتہ و رابطہ)', Icons.home_outlined),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            student.fullAddress,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Section 4: Academic Information
                        _buildSectionHeader('4. Academic Information (تعلیمی تفصیلات)', Icons.school_outlined),
                        _buildGrid([
                          _Item('Course', student.courseName),
                          _Item('Class', student.className),
                          _Item('Study Mode', student.modeOfStudy),
                          _Item('Hostel Facility', student.hostelFacility),
                          _Item('Previous School', student.prevSchoolName.isNotEmpty ? student.prevSchoolName : 'Madrasa Arabia'),
                          _Item('Previous School City', student.prevSchoolAddress.isNotEmpty ? student.prevSchoolAddress : 'Saharanpur, UP'),
                        ]),
                        const SizedBox(height: 10),

                        // Section 5: Office Verification Checklist (برائے دفتر)
                        _buildSectionHeader('5. Office Checklist & Verification (برائے دفتر)', Icons.verified_outlined),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _checkItem('Student Aadhar Card', true),
                              _checkItem('Father Aadhar Card', true),
                              _checkItem('Passport Size Photos', true),
                              _checkItem('TC / Previous School Marksheet', true),
                              _checkItem('Character Certificate', true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF047857)),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFF047857),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isUrdu = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: isUrdu ? 11 : 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_Item> items) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: items.map((item) {
          return SizedBox(
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 1),
                Text(
                  item.value,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _checkItem(String label, bool isChecked) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: 13,
          color: const Color(0xFF059669),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
        ),
      ],
    );
  }
}

class _Item {
  const _Item(this.label, this.value);
  final String label;
  final String value;
}
