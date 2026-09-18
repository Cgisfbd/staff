import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/attendance/data/datasources/student_attendance_datasource.dart';
import 'package:staff_app/features/attendance/domain/models/student_attendance_model.dart';
import 'package:staff_app/features/attendance/presentation/widgets/attendance_filter_card.dart';
import 'package:staff_app/features/attendance/presentation/widgets/attendance_hud_bar.dart';
import 'package:staff_app/features/attendance/presentation/widgets/student_attendance_row.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';

/// Institutional Student Attendance Hub (< 220 lines).
/// Equipped with Cascading Dropdowns, Real-Time HUD, Sharp-Cornered 3-Day History,
/// and Present / Absent / Leave (P / A / L) marking controls.
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<CourseEntity> _courses = StudentAttendanceDatasource.courses;
  late CourseEntity _selectedCourse;
  late List<ClassEntity> _currentClasses;
  ClassEntity? _selectedClass;
  List<StudentAttendanceItem> _students = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCourse = _courses.first;
    _currentClasses = StudentAttendanceDatasource.getClassesForCourse(_selectedCourse.id);
    _selectedClass = _currentClasses.isNotEmpty ? _currentClasses.first : null;
    _loadStudents();
  }

  void _loadStudents() {
    if (_selectedClass == null) {
      setState(() => _students = []);
      return;
    }
    final roster = StudentAttendanceDatasource.getStudentRoster(_selectedClass!.id);
    setState(() => _students = roster);
  }

  void _onCourseChanged(CourseEntity? newCourse) {
    if (newCourse == null || newCourse == _selectedCourse) return;
    setState(() {
      _selectedCourse = newCourse;
      _currentClasses = StudentAttendanceDatasource.getClassesForCourse(newCourse.id);
      _selectedClass = _currentClasses.isNotEmpty ? _currentClasses.first : null;
    });
    _loadStudents();
  }

  void _onClassChanged(ClassEntity? newClass) {
    if (newClass == null || newClass == _selectedClass) return;
    setState(() {
      _selectedClass = newClass;
    });
    _loadStudents();
  }

  void _updateStudentStatus(int index, AttendanceStatus newStatus) {
    setState(() {
      _students[index] = _students[index].copyWith(status: newStatus);
    });
  }

  void _markAllPresent() {
    setState(() {
      _students = _students
          .map((s) => s.copyWith(status: AttendanceStatus.present))
          .toList();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr(
                  'attendance_all_marked_present_msg',
                  params: {'count': '${_students.length}'},
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitAttendance() async {
    if (_selectedClass == null || _students.isEmpty) return;
    setState(() => _isSubmitting = true);

    await StudentAttendanceDatasource.submitAttendanceBatch(
      classId: _selectedClass!.id,
      students: _students,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('attendance_saved_success'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  int get _presentCount => _students.where((s) => s.isPresent).length;
  int get _absentCount => _students.where((s) => s.isAbsent).length;
  int get _leaveCount => _students.where((s) => s.isLeave).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Executive Top Header matching Settings & Menu
              ExecutiveTopHeader(
                icon: Icons.fact_check_rounded,
                title: context.tr('attendance_header_title'),
                subtitle: context.tr('attendance_header_subtitle'),
              ),

              // 2. Scrollable Body
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  children: [
                    // A. Cascading Course & Class Dropdowns Card
                    AttendanceFilterCard(
                      courses: _courses,
                      classes: _currentClasses,
                      selectedCourse: _selectedCourse,
                      selectedClass: _selectedClass,
                      onCourseChanged: _onCourseChanged,
                      onClassChanged: _onClassChanged,
                    ),
                    const SizedBox(height: 10),

                    // B. Live Attendance HUD Summary Bar
                    AttendanceHudBar(
                      totalStudents: _students.length,
                      presentCount: _presentCount,
                      absentCount: _absentCount,
                      leaveCount: _leaveCount,
                      onMarkAllPresent: _markAllPresent,
                    ),
                    const SizedBox(height: 12),

                    // C. Single Master Luxury Card for Student Attendance Roster
                    _buildRosterCard(isDark, isRtl),

                    const SizedBox(height: 12),

                    // D. Save / Submit Attendance Button
                    if (_students.isNotEmpty)
                      _buildSubmitButton(isDark, isRtl),

                    const SizedBox(height: 96), // Clearance for bottom navigation bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRosterCard(bool isDark, bool isRtl) {
    if (_students.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x3D1E293B),
                      const Color(0x240F172A),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFFFBF8F3).withValues(alpha: 0.88),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.goldPrimary.withValues(alpha: 0.38)
                  : AppColors.goldPrimary.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Roster Card Header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldPrimary, AppColors.goldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedClass != null
                                ? _selectedClass!.localizedName(isRtl, context.currentLanguageCode, context)
                                : context.tr('attendance_roster_title'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            context.tr('attendance_daily_register'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        context.tr(
                          'attendance_students_count',
                          params: {'count': '${_students.length}'},
                        ),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Gold Hairline separator
              Container(
                height: 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.goldPrimary.withValues(alpha: isDark ? 0.30 : 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Roster List inside this single card
              ...List.generate(_students.length, (index) {
                final student = _students[index];
                final isLast = index == _students.length - 1;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StudentAttendanceRow(
                      student: student,
                      onStatusChanged: (newStatus) => _updateStudentStatus(index, newStatus),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 0.7,
                        indent: 58,
                        endIndent: 12,
                        color: isDark
                            ? const Color(0x3364748B)
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark, bool isRtl) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldPrimary, AppColors.goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : _submitAttendance,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  const Icon(Icons.cloud_upload_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('attendance_save_btn'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_off_rounded,
            size: 40,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('attendance_empty_roster'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
