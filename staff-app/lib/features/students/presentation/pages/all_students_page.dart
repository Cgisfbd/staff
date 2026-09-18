import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/core/widgets/pdf/global_pdf_viewer.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';
import 'package:staff_app/features/students/presentation/bloc/student_directory_bloc.dart';
import 'package:staff_app/features/students/presentation/pages/student_admission_page.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_directory_table.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_export_dialog.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_kpi_carousel.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_pdf_generator.dart';
import 'package:staff_app/features/students/presentation/widgets/directory/student_search_filter_bar.dart';

/// Master Screen for the Student Directory & Records Hub (< 260 lines).
/// Features a pristine executive top bar with left-aligned back button, export download, and ERP data table.
class AllStudentsPage extends StatefulWidget {
  const AllStudentsPage({super.key});

  @override
  State<AllStudentsPage> createState() => _AllStudentsPageState();
}

class _AllStudentsPageState extends State<AllStudentsPage> {
  late final StudentDirectoryBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<StudentDirectoryBloc>()..add(const LoadStudentDirectoryEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openStudentAdmissionPdf(StudentDirectoryEntity student) {
    final cleanName = student.fullNameEn.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    GlobalPdfViewer.open<void>(
      context,
      title: 'Admission Form - ${student.fullNameEn}',
      fileName: 'Admission_Form_${student.rollNo}_$cleanName',
      subtitle: 'Roll No: ${student.rollNo} • ${student.courseName} (${student.className})',
      pdfBytesFuture: () => StudentPdfGenerator.generateAdmissionFormPdf(student),
      actions: [
        // 1. Edit Record Action Button
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InkWell(
            onTap: () async {
              final updated = await Navigator.of(context).push<StudentDirectoryEntity>(
                MaterialPageRoute(
                  builder: (_) => StudentAdmissionPage(
                    initialStudent: student,
                    isEditMode: true,
                  ),
                ),
              );
              if (updated != null && mounted) {
                _bloc.add(const RefreshStudentDirectoryEvent());
              }
            },
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Direct Print Action Button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () async {
              try {
                final bytes = await StudentPdfGenerator.generateAdmissionFormPdf(student);
                await Printing.layoutPdf(
                  onLayout: (_) async => bytes,
                  name: 'Admission_Form_${student.rollNo}_$cleanName',
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Print error: $e')),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.print_rounded, size: 15, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Print',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: AppBackground(
          useSafeArea: false,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Executive Top Header (Identical to Student Admission Form)
                BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
                  builder: (context, state) {
                    final currentList = state is StudentDirectoryLoaded
                        ? state.filteredStudents
                        : <StudentDirectoryEntity>[];
                    return ExecutiveTopHeader(
                      icon: Icons.people_alt_rounded,
                      title: 'Student Directory',
                      subtitle: 'Central student bio records & status roster',
                      onIconTap: () => Navigator.of(context).maybePop(),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Export / Download CSV Button
                          InkWell(
                            onTap: currentList.isEmpty
                                ? null
                                : () => StudentExportDialog.show(
                                      context,
                                      state is StudentDirectoryLoaded ? state.students : currentList,
                                    ),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(7.5),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                  width: 0.9,
                                ),
                              ),
                              child: Icon(
                                Icons.file_download_outlined,
                                size: 18,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // New Admission CTA Button
                          InkWell(
                            onTap: () => context.push(RouteNames.studentAdmission),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.goldPrimary, AppColors.goldDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.28),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_add_rounded, size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Admission',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 2. Main Content Body with BlocBuilder
                Expanded(
                  child: BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
                    builder: (context, state) {
                      if (state is StudentDirectoryLoading || state is StudentDirectoryInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                          ),
                        );
                      }

                      if (state is StudentDirectoryError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 44, color: Color(0xFFF43F5E)),
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _bloc.add(const RefreshStudentDirectoryEvent()),
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is StudentDirectoryLoaded) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            _bloc.add(const RefreshStudentDirectoryEvent());
                          },
                          color: AppColors.goldPrimary,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(top: 8, bottom: 36),
                            children: [
                              // A. 7-Metric Zero-Swipe KPI Deck
                              StudentKPICarousel(stats: state.stats),
                              const SizedBox(height: 12),

                              // B. Search & Multi-Filters Bar
                              StudentSearchFilterBar(
                                searchController: _searchController,
                                onSearchChanged: (q) => _bloc.add(SearchStudentsEvent(q)),
                                selectedStatus: state.selectedStatus,
                                onStatusSelected: (status) => _bloc.add(FilterStudentsEvent(status: status)),
                                selectedMode: state.selectedMode,
                                onModeSelected: (mode) => _bloc.add(FilterStudentsEvent(mode: mode)),
                                totalMatches: state.filteredStudents.length,
                              ),
                              const SizedBox(height: 12),

                              // Records Header Label with Count & Swipe Indicator
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'STUDENT RECORDS',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.6,
                                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            '${state.filteredStudents.length} Found',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.goldDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Swipe table ➔',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // C. Compact Liquid Crystal Glass Data Table (With Address & Course First)
                              StudentDirectoryTable(
                                students: state.filteredStudents,
                                onStudentTap: (student) => _openStudentAdmissionPdf(student),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
