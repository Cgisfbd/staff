import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/features/examination/data/datasources/examination_datasource.dart';
import 'package:staff_app/features/examination/data/datasources/results_mock_datasource.dart';
import 'package:staff_app/features/examination/domain/models/academic_filter_model.dart';
import 'package:staff_app/features/examination/domain/models/student_result_model.dart';
import 'package:staff_app/features/examination/domain/services/result_pdf_generator.dart';
import 'package:staff_app/features/pdf_viewer/presentation/pages/pdf_viewer_page.dart';

/// Ultra-Luxury Examination Results Screen (< 450 lines).
/// Built with 100% identical styling, luxury gold accents, and headers as My Salary (StaffSalaryPage).
class ExaminationResultsPage extends StatefulWidget {
  const ExaminationResultsPage({super.key});

  @override
  State<ExaminationResultsPage> createState() => _ExaminationResultsPageState();
}

enum ResultScope { classWise, courseWise, instituteWide }

class _ExaminationResultsPageState extends State<ExaminationResultsPage> {
  final ExaminationDatasource _hierarchyDatasource = const ExaminationDatasource();
  final ResultsMockDatasource _resultsDatasource = const ResultsMockDatasource();

  late List<CourseEntity> _courses;
  late List<ClassEntity> _classes;
  CourseEntity? _selectedCourse;
  ClassEntity? _selectedClass;

  ResultScope _currentScope = ResultScope.classWise;
  bool _showToppersOnly = false;

  List<StudentResultModel> _allStudents = [];
  List<StudentResultModel> _filteredStudents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _courses = _hierarchyDatasource.getCourses();
    if (_courses.isNotEmpty) {
      _selectedCourse = _courses.first;
      _classes = _hierarchyDatasource.getClasses(_selectedCourse!.id);
      if (_classes.isNotEmpty) {
        _selectedClass = _classes.first;
        _loadResults();
      } else {
        _classes = [];
      }
    } else {
      _classes = [];
    }
  }

  void _loadResults() {
    List<StudentResultModel> list = [];
    if (_currentScope == ResultScope.instituteWide) {
      list = _resultsDatasource.getAllInstituteResults();
    } else if (_currentScope == ResultScope.courseWise) {
      if (_selectedCourse != null) {
        list = _resultsDatasource.getCourseResults(_selectedCourse!.nameEnglish);
      }
    } else {
      if (_selectedClass != null) {
        list = _resultsDatasource.getClassResults(_selectedClass!.id);
      }
    }
    setState(() {
      _allStudents = list;
      _applySearch();
    });
  }

  void _applySearch() {
    List<StudentResultModel> base = _allStudents;
    if (_showToppersOnly) {
      base = base.where((s) => s.rank != null && s.rank! <= 3 && s.resultStatus == 'PASSED').toList();
    }
    if (_searchQuery.trim().isEmpty) {
      _filteredStudents = List.from(base);
    } else {
      final query = _searchQuery.toLowerCase().trim();
      _filteredStudents = base.where((s) {
        return s.nameEnglish.toLowerCase().contains(query) ||
            s.nameUrdu.contains(query) ||
            s.rollNo.contains(query) ||
            s.admissionNo.toLowerCase().contains(query);
      }).toList();
    }
  }

  List<StudentResultModel> get _topRankers {
    final list = _allStudents
        .where((s) => s.rank != null && s.rank! <= 3 && s.resultStatus == 'PASSED')
        .toList();
    list.sort((a, b) => (a.rank ?? 99).compareTo(b.rank ?? 99));
    return list;
  }

  void _openClassTabulationPdf() {
    if (_allStudents.isEmpty) return;

    final String title;
    final String subtitle;
    final String fileName;
    final String className;
    final String courseName;

    if (_currentScope == ResultScope.instituteWide) {
      title = 'Institute Master Gazette';
      subtitle = 'Complete Institutional Tabulation Sheet';
      fileName = 'Institute_Master_Gazette';
      className = 'Entire Institute';
      courseName = 'All Academic Courses';
    } else if (_currentScope == ResultScope.courseWise) {
      final cName = _selectedCourse?.nameEnglish ?? 'Course';
      title = '$cName Gazette';
      subtitle = 'Course-wide Tabulation Sheet';
      fileName = '${cName.replaceAll(" ", "_")}_Gazette';
      className = 'All Classes';
      courseName = cName;
    } else {
      final cName = _selectedClass?.nameEnglish ?? 'Class';
      title = 'Class Tabulation Sheet';
      subtitle = '$cName | Master Gazette';
      fileName = '${cName.replaceAll(" ", "_")}_Tabulation_Gazette';
      className = cName;
      courseName = _selectedCourse?.nameEnglish ?? '';
    }

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfViewerPage(
          title: title,
          subtitle: subtitle,
          fileName: fileName,
          isLandscape: true,
          pdfBytesFuture: () => ResultPdfGenerator.generateClassTabulationPdf(
            className: className,
            courseName: courseName,
            students: _allStudents,
            session: ResultsMockDatasource.currentSession,
          ),
        ),
      ),
    );
  }

  void _openStudentMarksheetPdf(StudentResultModel student) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => PdfViewerPage(
          title: student.nameEnglish,
          subtitle: 'Roll #${student.rollNo} | Marksheet',
          fileName: '${student.rollNo}_${student.nameEnglish.replaceAll(" ", "_")}_Marksheet',
          isLandscape: false,
          pdfBytesFuture: () => ResultPdfGenerator.generateStudentMarksheetPdf(student),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar identical to StaffSalaryPage
              _buildTopBar(context, isDark, isRtl),

              // Scrollable Content
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
                  children: [
                    // 1. Academic Hierarchy Selector Deck (Scope Pills + Dynamic Filters)
                    _buildAcademicFilterDeck(isDark),
                    const SizedBox(height: 14),

                    // 2. Tabulation Master Gazette Card (Class / Course / Institute)
                    _buildClassTabulationCard(isDark),
                    const SizedBox(height: 16),

                    // 3. Toppers Spotlight Leaderboard Podium (When Toppers Exist)
                    if (_topRankers.isNotEmpty) ...[
                      _buildTopperPodiumDeck(isDark),
                      const SizedBox(height: 16),
                    ],

                    // 4. Enclosed Single-Card Student Marksheets Roster
                    _buildEnclosedStudentRosterCard(isDark),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Navigation Bar (Identical to StaffSalaryPage)
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(BuildContext context, bool isDark, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.9,
                ),
              ),
              child: Icon(
                isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('results_title'),
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.tr('results_subtitle'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.50 : 0.35),
                width: 1.0,
              ),
            ),
            child: Text(
              '2025-26',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Academic Hierarchy Selector Deck (Scope Pills + Dynamic Hierarchy)
  // ---------------------------------------------------------------------------
  Widget _buildAcademicFilterDeck(bool isDark) {
    return _buildLuxuryCardContainer(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 12, color: AppColors.goldPrimary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'RESULT SCOPE & HIERARCHY',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_filteredStudents.length} Students',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 1. Scope Pills: Class-wise | Course-wise | All Institute
          _buildScopePills(isDark),
          const SizedBox(height: 10),

          // 2. Dynamic Selector based on selected Scope
          if (_currentScope == ResultScope.classWise) ...[
            Row(
              children: [
                // 1. Course Dropdown
                Expanded(
                  child: _buildLuxuryDropdown(
                    isDark: isDark,
                    label: context.tr('exam_sel_course'),
                    icon: Icons.school_rounded,
                    value: _selectedCourse?.nameEnglish,
                    items: _courses.map((c) => c.nameEnglish).toList(),
                    onChanged: (val) {
                      final found = _courses.firstWhere((c) => c.nameEnglish == val);
                      setState(() {
                        _selectedCourse = found;
                        _classes = _hierarchyDatasource.getClasses(found.id);
                        _selectedClass = _classes.isNotEmpty ? _classes.first : null;
                        _loadResults();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 2. Class Dropdown
                Expanded(
                  child: _buildLuxuryDropdown(
                    isDark: isDark,
                    label: context.tr('exam_sel_class'),
                    icon: Icons.meeting_room_rounded,
                    value: _selectedClass?.nameEnglish,
                    items: _classes.map((c) => c.nameEnglish).toList(),
                    onChanged: (val) {
                      final found = _classes.firstWhere((c) => c.nameEnglish == val);
                      setState(() {
                        _selectedClass = found;
                        _loadResults();
                      });
                    },
                  ),
                ),
              ],
            ),
          ] else if (_currentScope == ResultScope.courseWise) ...[
            _buildLuxuryDropdown(
              isDark: isDark,
              label: 'SELECT COURSE / DEPARTMENT',
              icon: Icons.school_rounded,
              value: _selectedCourse?.nameEnglish,
              items: _courses.map((c) => c.nameEnglish).toList(),
              onChanged: (val) {
                final found = _courses.firstWhere((c) => c.nameEnglish == val);
                setState(() {
                  _selectedCourse = found;
                  _loadResults();
                });
              },
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 0.9,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 16, color: AppColors.goldPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Institute-Wide Consolidated Merit (All Courses & Classes)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScopePills(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.18),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          _buildScopeTabItem(
            isDark: isDark,
            label: 'Class-wise',
            icon: Icons.meeting_room_rounded,
            scope: ResultScope.classWise,
          ),
          _buildScopeTabItem(
            isDark: isDark,
            label: 'Course-wise',
            icon: Icons.school_rounded,
            scope: ResultScope.courseWise,
          ),
          _buildScopeTabItem(
            isDark: isDark,
            label: 'All Institute',
            icon: Icons.account_balance_rounded,
            scope: ResultScope.instituteWide,
          ),
        ],
      ),
    );
  }

  Widget _buildScopeTabItem({
    required bool isDark,
    required String label,
    required IconData icon,
    required ResultScope scope,
  }) {
    final isSelected = _currentScope == scope;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentScope = scope;
            _loadResults();
          });
        },
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryDropdown({
    required bool isDark,
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x33FFFFFF) : Colors.white).withValues(alpha: isDark ? 0.08 : 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.32 : 0.24),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: isDark ? AppColors.goldChampagne : AppColors.goldDark),
              const SizedBox(width: 3),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              selectedItemBuilder: (context) {
                return items.map((name) {
                  return Align(
                    alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList();
              },
              items: items.map((name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Tabulation Master Gazette Card (Dynamic per scope)
  // ---------------------------------------------------------------------------
  Widget _buildClassTabulationCard(bool isDark) {
    final String cardTitle;
    final String cardSub;
    final String buttonLabel;

    if (_currentScope == ResultScope.instituteWide) {
      cardTitle = 'Institute Master Gazette';
      cardSub = 'Complete tabulation sheet for all enrolled students in the institute';
      buttonLabel = 'Open Institute Master Gazette PDF';
    } else if (_currentScope == ResultScope.courseWise) {
      cardTitle = '${_selectedCourse?.nameEnglish ?? "Course"} Master Gazette';
      cardSub = 'Consolidated tabulation sheet for all classes in this degree';
      buttonLabel = 'Open Course Master Gazette PDF';
    } else {
      cardTitle = context.tr('class_tabulation_card_title');
      cardSub = context.tr('class_tabulation_card_sub');
      buttonLabel = context.tr('open_tabulation_pdf');
    }

    return _buildLuxuryCardContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goldPrimary.withValues(alpha: 0.25),
                      AppColors.goldPrimary.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.45),
                    width: 1.1,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.table_chart_rounded, color: AppColors.goldPrimary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        cardTitle,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cardSub,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _allStudents.isEmpty ? null : _openClassTabulationPdf,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Toppers Podium / Leaderboard Deck
  // ---------------------------------------------------------------------------
  Widget _buildTopperPodiumDeck(bool isDark) {
    final toppers = _topRankers;
    if (toppers.isEmpty) return const SizedBox.shrink();

    return _buildLuxuryCardContainer(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.emoji_events_rounded, color: Colors.black87, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOP RANKERS SPOTLIGHT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentScope == ResultScope.instituteWide
                          ? 'Institute-wide highest scoring toppers'
                          : (_currentScope == ResultScope.courseWise
                              ? '${_selectedCourse?.nameEnglish ?? "Course"} top performers'
                              : '${_selectedClass?.nameEnglish ?? "Class"} position holders'),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '${toppers.length} Toppers',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: toppers.map((student) {
                final rank = student.rank ?? 1;
                final Color medalColor = rank == 1
                    ? const Color(0xFFFFD700)
                    : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));
                final String medalEmoji = rank == 1 ? '🥇 1st' : (rank == 2 ? '🥈 2nd' : '🥉 3rd');

                return Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.75),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: medalColor.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: medalColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: medalColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              medalEmoji,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '${student.percentage}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        student.nameEnglish,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        student.nameUrdu,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.className,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openStudentMarksheetPdf(student),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.goldPrimary.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, size: 12, color: AppColors.goldPrimary),
                              SizedBox(width: 4),
                              Text(
                                'Marksheet',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.goldPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Enclosed Single-Card Student Marksheets Roster
  // ---------------------------------------------------------------------------
  Widget _buildEnclosedStudentRosterCard(bool isDark) {
    return _buildLuxuryCardContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single Card Header: Icon + Title + Class Badge
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.people_alt_rounded,
                    size: 15,
                    color: AppColors.goldPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    context.tr(
                      'enrolled_students_count',
                      params: {'count': '${_filteredStudents.length}'},
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _currentScope == ResultScope.instituteWide
                      ? 'All Institute'
                      : (_currentScope == ResultScope.courseWise
                          ? (_selectedCourse?.code ?? 'Course')
                          : (_selectedClass?.nameEnglish ?? 'Class')),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Filter Switch: All Students vs Toppers Only
          Row(
            children: [
              _buildRosterFilterPill(
                isDark: isDark,
                label: 'All Students (${_allStudents.length})',
                isSelected: !_showToppersOnly,
                onTap: () {
                  setState(() {
                    _showToppersOnly = false;
                    _applySearch();
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildRosterFilterPill(
                isDark: isDark,
                label: '🏆 Toppers (${_topRankers.length})',
                isSelected: _showToppersOnly,
                onTap: () {
                  setState(() {
                    _showToppersOnly = true;
                    _applySearch();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Integrated Search Bar inside the Single Card
          Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.30 : 0.22),
                width: 1.0,
              ),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applySearch();
                });
              },
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.tr('search_student_result_hint'),
                hintStyle: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),

          // The Roster Content inside the Single Card
          if (_filteredStudents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      size: 36,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No student records found matching search or filter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredStudents.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return _buildStudentRosterRow(context, student, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentRosterRow(
    BuildContext context,
    StudentResultModel student,
    bool isDark,
  ) {
    final isPassed = student.isPassed;
    final isAbsent = student.isAbsent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openStudentMarksheetPdf(student),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              // Roll No Avatar Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPassed
                        ? [AppColors.goldPrimary, AppColors.goldDark]
                        : isAbsent
                            ? [Colors.grey.shade600, Colors.grey.shade800]
                            : [AppColors.statusAbsent, Colors.red.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (isPassed ? AppColors.goldPrimary : Colors.black).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  student.rollNo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Student Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student.nameEnglish,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            student.nameUrdu,
                            style: TextStyle(
                              fontFamily: 'Alyamama',
                              fontSize: 12,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        "S/O: ${student.fatherNameEnglish}",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Marks Pill Summary
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: context.isRtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: (isPassed
                                      ? AppColors.goldPrimary
                                      : isAbsent
                                          ? Colors.grey
                                          : AppColors.statusAbsent)
                                  .withValues(alpha: isDark ? 0.20 : 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: (isPassed
                                        ? AppColors.goldPrimary
                                        : isAbsent
                                            ? Colors.grey
                                            : AppColors.statusAbsent)
                                    .withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isPassed
                                  ? context.tr('status_passed')
                                  : isAbsent
                                      ? context.tr('status_absent')
                                      : context.tr('status_failed'),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isPassed
                                    ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                                    : isAbsent
                                        ? (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted)
                                        : AppColors.statusAbsent,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAbsent
                                ? context.tr('status_absent')
                                : context.tr(
                                    'marks_summary_label',
                                    params: {
                                      'obtained': '${student.totalObtained}',
                                      'total': '${student.totalMax}',
                                      'percentage': student.percentage.toStringAsFixed(0),
                                    },
                                  ),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isPassed
                                  ? (isDark ? AppColors.goldChampagne : AppColors.goldDark)
                                  : isAbsent
                                      ? (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted)
                                      : AppColors.statusAbsent,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // View Marksheet PDF Action Button
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 16,
                    color: AppColors.goldPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Luxury Card Container (Exact copy of StaffSalaryPage._buildOverviewChartCard)
  // ---------------------------------------------------------------------------
  Widget _buildLuxuryCardContainer({
    required Widget child,
    required bool isDark,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x661E293B),
                      const Color(0x520F172A),
                      const Color(0x5C1E293B),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.96),
                      const Color(0xF7F8FAFC),
                      Colors.white.withValues(alpha: 0.94),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.45 : 0.10),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildRosterFilterPill({
    required bool isDark,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.goldPrimary
                : (isDark ? Colors.white12 : Colors.black12),
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
          ),
        ),
      ),
    );
  }
}

