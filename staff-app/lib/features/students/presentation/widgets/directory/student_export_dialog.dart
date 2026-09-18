import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_pdf_generator.dart';

/// Field metadata definition for customizable CSV export.
class ExportFieldOption {
  const ExportFieldOption({
    required this.id,
    required this.label,
    required this.category,
    required this.getValue,
  });

  final String id;
  final String label;
  final String category;
  final String Function(StudentDirectoryEntity s) getValue;
}

/// All exportable fields mirroring ERP StudentExportConfig.ts.
final List<ExportFieldOption> allExportFields = [
  // Basic Details
  ExportFieldOption(id: 'rollNo', label: 'Roll No', category: 'Basic', getValue: (s) => '${s.rollNo}'),
  ExportFieldOption(id: 'fullNameEn', label: 'Full Name (English)', category: 'Basic', getValue: (s) => s.fullNameEn),
  ExportFieldOption(id: 'nameUrdu', label: 'Name (Urdu)', category: 'Basic', getValue: (s) => s.nameUrdu),

  // Family Details
  ExportFieldOption(id: 'fatherNameEn', label: 'Father Name', category: 'Family', getValue: (s) => s.fatherNameEn),
  ExportFieldOption(id: 'motherNameEn', label: 'Mother Name', category: 'Family', getValue: (s) => s.motherNameEn),

  // Personal Details
  ExportFieldOption(id: 'dob', label: 'Date of Birth', category: 'Personal', getValue: (s) => s.dob),
  ExportFieldOption(id: 'gender', label: 'Gender', category: 'Personal', getValue: (s) => s.gender),
  ExportFieldOption(id: 'caste', label: 'Caste / Biradri', category: 'Personal', getValue: (s) => s.caste),
  ExportFieldOption(id: 'aadharNo', label: 'Aadhar Number', category: 'Personal', getValue: (s) => s.aadharNo),

  // Contact Details
  ExportFieldOption(id: 'mobile', label: 'Mobile Number', category: 'Contact', getValue: (s) => s.mobile),
  ExportFieldOption(id: 'altMobile', label: 'Alt Mobile Number', category: 'Contact', getValue: (s) => s.altMobile),

  // Address Details
  ExportFieldOption(id: 'address', label: 'Full Address', category: 'Address', getValue: (s) => s.fullAddress),

  // Academic Details
  ExportFieldOption(id: 'course', label: 'Course', category: 'Academic', getValue: (s) => s.courseName),
  ExportFieldOption(id: 'class', label: 'Class', category: 'Academic', getValue: (s) => s.className),
  ExportFieldOption(id: 'modeOfStudy', label: 'Study Mode', category: 'Academic', getValue: (s) => s.modeOfStudy),
  ExportFieldOption(id: 'hostelFacility', label: 'Hostel Facility', category: 'Academic', getValue: (s) => s.hostelFacility),
  ExportFieldOption(id: 'rfidNo', label: 'RFID Card No', category: 'Academic', getValue: (s) => s.rfidNo),

  // Status Details
  ExportFieldOption(id: 'status', label: 'Account Status', category: 'Status', getValue: (s) => s.status),
];

/// Advanced Export Manager Dialog mirroring ERP Advanced Export Popover.
/// Features Scope Filters (Course, Class, Status, Study Mode) and Column Checkboxes.
class StudentExportDialog extends StatefulWidget {
  const StudentExportDialog({
    super.key,
    required this.students,
  });

  final List<StudentDirectoryEntity> students;

  static void show(BuildContext context, List<StudentDirectoryEntity> students) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentExportDialog(students: students),
    );
  }

  @override
  State<StudentExportDialog> createState() => _StudentExportDialogState();
}

class _StudentExportDialogState extends State<StudentExportDialog> {
  late Set<String> _selectedFieldIds;
  String _exportCourse = 'All';
  String _exportClass = 'All';
  String _exportStatus = 'All';
  String _exportMode = 'All';

  @override
  void initState() {
    super.initState();
    _selectedFieldIds = allExportFields.map((f) => f.id).toSet();
  }

  List<StudentDirectoryEntity> get _filteredStudents {
    return widget.students.where((s) {
      final matchCourse = _exportCourse == 'All' || s.courseName.toLowerCase() == _exportCourse.toLowerCase();
      final matchClass = _exportClass == 'All' || s.className.toLowerCase() == _exportClass.toLowerCase();
      final matchStatus = _exportStatus == 'All' ||
          s.status.toLowerCase() == _exportStatus.toLowerCase() ||
          (_exportStatus.toLowerCase() == 'suspend' && s.status.toLowerCase() == 'suspended') ||
          (_exportStatus.toLowerCase() == 'suspended' && s.status.toLowerCase() == 'suspend') ||
          (_exportStatus.toLowerCase() == 'graduate' && s.status.toLowerCase() == 'graduated') ||
          (_exportStatus.toLowerCase() == 'graduated' && s.status.toLowerCase() == 'graduate');
      final matchMode = _exportMode == 'All' || s.modeOfStudy.toLowerCase() == _exportMode.toLowerCase();
      return matchCourse && matchClass && matchStatus && matchMode;
    }).toList();
  }

  List<String> get _courseOptions {
    final set = widget.students.map((s) => s.courseName).where((c) => c.isNotEmpty).toSet();
    return ['All', ...set];
  }

  List<String> get _classOptions {
    final set = widget.students.map((s) => s.className).where((c) => c.isNotEmpty).toSet();
    return ['All', ...set];
  }

  String _generateCSV() {
    final buffer = StringBuffer();
    // Prepend UTF-8 BOM for Microsoft Excel / Google Sheets compatibility
    buffer.write('\uFEFF');

    final fieldsToExport = allExportFields.where((f) => _selectedFieldIds.contains(f.id)).toList();

    // Headers
    buffer.writeln(fieldsToExport.map((f) => '"${f.label.replaceAll('"', '""')}"').join(','));

    // Data rows
    for (final s in _filteredStudents) {
      final row = fieldsToExport.map((f) => '"${f.getValue(s).replaceAll('"', '""')}"').join(',');
      buffer.writeln(row);
    }
    return buffer.toString();
  }

  bool _isExportingCsv = false;

  Future<void> _downloadCSV() async {
    if (_selectedFieldIds.isEmpty || _filteredStudents.isEmpty || _isExportingCsv) return;
    setState(() => _isExportingCsv = true);
    try {
      final csvContent = _generateCSV();
      final dateStr = DateTime.now().toIso8601String().split('T').first;
      final fileName = 'students_export_$dateStr.csv';

      // 1. Try writing directly to public Android Download folder
      try {
        final publicDownloadDir = Directory('/storage/emulated/0/Download');
        if (await publicDownloadDir.exists()) {
          final pubFile = File('${publicDownloadDir.path}/$fileName');
          await pubFile.writeAsString(csvContent);
        }
      } catch (_) {}

      // 2. Save to internal app documents directory as fallback
      final appDir = await getApplicationDocumentsDirectory();
      final appFile = File('${appDir.path}/$fileName');
      await appFile.writeAsString(csvContent);

      // 3. Copy CSV text to Clipboard so user immediately has it ready to paste
      await Clipboard.setData(ClipboardData(text: csvContent));

      // 4. Capture ScaffoldMessenger before popping
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saved ${_filteredStudents.length} students CSV to Downloads & Copied to Clipboard!',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );

      // 5. Open native Share/Send Sheet so user can save to files, drive, whatsapp, or excel
      try {
        await Printing.sharePdf(
          bytes: Uint8List.fromList(utf8.encode(csvContent)),
          filename: fileName,
          subject: 'Student Directory CSV Export',
        );
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV Export error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingCsv = false);
      }
    }
  }

  void _copyCSV() {
    if (_selectedFieldIds.isEmpty || _filteredStudents.isEmpty) return;
    final csvContent = _generateCSV();
    Clipboard.setData(ClipboardData(text: csvContent));
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy_all_rounded, color: AppColors.goldPrimary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Copied ${_filteredStudents.length} students (${_selectedFieldIds.length} columns) to clipboard!',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _isGeneratingPdf = false;

  Future<void> _exportPDF() async {
    if (_selectedFieldIds.isEmpty || _filteredStudents.isEmpty || _isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);
    try {
      final selectedFields = allExportFields.where((f) => _selectedFieldIds.contains(f.id)).toList();
      final file = await StudentPdfGenerator.exportAndOpenPdf(
        students: _filteredStudents,
        selectedFields: selectedFields,
        courseFilter: _exportCourse,
        classFilter: _exportClass,
        statusFilter: _exportStatus,
        modeFilter: _exportMode,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exported PDF (${_filteredStudents.length} records) to ${file.path.split('/').last}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF export error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredCount = _filteredStudents.length;
    final canExport = _selectedFieldIds.isNotEmpty && filteredCount > 0;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: isDark ? 0.92 : 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.9),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldPrimary, AppColors.goldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.table_chart_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advanced Export Manager',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          Text(
                            'Custom filters scope & column field selector',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: isDark ? Colors.white54 : Colors.black45,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.7),

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Export Scope Filter Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0x281E293B) : const Color(0xFFF8FAFC)).withValues(alpha: isDark ? 0.5 : 0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.filter_list_rounded, size: 14, color: Color(0xFF10B981)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Export Filters Scope',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.7),
                                  ),
                                  child: Text(
                                    '$filteredCount Students Selected',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Grid of 4 Filter Dropdowns
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Course',
                                    value: _exportCourse,
                                    items: _courseOptions,
                                    onChanged: (val) => setState(() => _exportCourse = val),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Class',
                                    value: _exportClass,
                                    items: _classOptions,
                                    onChanged: (val) => setState(() => _exportClass = val),
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Status',
                                    value: _exportStatus,
                                    items: const ['All', 'Active', 'Dropout', 'Suspend', 'Graduate'],
                                    onChanged: (val) => setState(() => _exportStatus = val),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Study Mode',
                                    value: _exportMode,
                                    items: const ['All', 'Offline', 'Online'],
                                    onChanged: (val) => setState(() => _exportMode = val),
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. Column Selection Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Select Columns to Export',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_selectedFieldIds.length}/${allExportFields.length}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _selectedFieldIds = allExportFields.map((f) => f.id).toSet()),
                                child: const Text(
                                  'Select All',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                              const Text('  •  ', style: TextStyle(fontSize: 9, color: Colors.grey)),
                              InkWell(
                                onTap: () => setState(() => _selectedFieldIds.clear()),
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 3. Field Checkbox Chips Wrap
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: allExportFields.map((field) {
                          final isSelected = _selectedFieldIds.contains(field.id);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFieldIds.remove(field.id);
                                } else {
                                  _selectedFieldIds.add(field.id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF10B981).withValues(alpha: 0.14)
                                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                      : (isDark ? Colors.white10 : Colors.black12),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                    size: 13,
                                    color: isSelected ? const Color(0xFF059669) : (isDark ? Colors.white38 : Colors.black38),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    field.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                                          : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      if (_selectedFieldIds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '⚠️ Please select at least one column to export.',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                          ),
                        ),

                      if (filteredCount == 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '⚠️ No students match the active scope filters.',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, thickness: 0.7),

              // Bottom Action Buttons
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: Dual Export Actions (Download CSV & Export PDF)
                      Row(
                        children: [
                          // 1. Download CSV Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: canExport && !_isExportingCsv ? _downloadCSV : null,
                              icon: _isExportingCsv
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.table_view_rounded, size: 15),
                              label: Text(
                                _isExportingCsv ? 'Saving...' : 'Download CSV ($filteredCount)',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.25),
                                disabledForegroundColor: Colors.white38,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: canExport ? 2 : 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 2. Export PDF Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: canExport && !_isGeneratingPdf ? _exportPDF : null,
                              icon: _isGeneratingPdf
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.picture_as_pdf_rounded, size: 15),
                              label: Text(
                                _isGeneratingPdf ? 'Generating...' : 'Export PDF ($filteredCount)',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.25),
                                disabledForegroundColor: Colors.white38,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: canExport ? 2 : 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Row 2: Copy CSV Quick Action
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: canExport ? _copyCSV : null,
                          icon: const Icon(Icons.copy_all_rounded, size: 15),
                          label: const Text(
                            'Copy CSV to Clipboard',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            side: BorderSide(
                              color: AppColors.goldPrimary.withValues(alpha: canExport ? 0.45 : 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
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

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.8,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : 'All',
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: isDark ? Colors.white54 : Colors.black45),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'All' ? 'All $label' : item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
