import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/core/widgets/pdf/global_pdf_viewer.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';
import 'package:staff_app/features/staff/presentation/bloc/teacher_directory_bloc.dart';
import 'package:staff_app/features/staff/presentation/pages/add_teacher_page.dart';
import 'package:staff_app/features/staff/presentation/widgets/staff_directory_table.dart';
import 'package:staff_app/features/staff/presentation/widgets/staff_kpi_carousel.dart';
import 'package:staff_app/features/staff/presentation/widgets/staff_search_filter_bar.dart';
import 'package:staff_app/features/staff/presentation/widgets/teacher_pdf_generator.dart';

/// Master Screen for Faculty & Staff Directory Hub (< 280 lines).
/// Perfectly mirrors AllStudentsPage with Executive Top Header, Zero-Swipe KPI deck,
/// real-time search & filters, liquid crystal cards, and Printable PDF Dossier.
class AllTeachersPage extends StatefulWidget {
  const AllTeachersPage({super.key});

  @override
  State<AllTeachersPage> createState() => _AllTeachersPageState();
}

class _AllTeachersPageState extends State<AllTeachersPage> {
  late final TeacherDirectoryBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<TeacherDirectoryBloc>()..add(const LoadTeacherDirectoryEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openFacultyDossierPdf(TeacherDirectoryEntity teacher) {
    final cleanName = teacher.fullNameEn.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    GlobalPdfViewer.open<void>(
      context,
      title: 'Faculty Dossier - ${teacher.fullNameEn}',
      fileName: 'Faculty_Dossier_${teacher.staffCode}_$cleanName',
      subtitle: 'Code: #${teacher.staffCode} • ${teacher.designation} (${teacher.qualification})',
      pdfBytesFuture: () => TeacherPdfGenerator.generateFacultyDossierPdf(teacher),
      actions: [
        // 1. Edit Record Action Button
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InkWell(
            onTap: () async {
              final updated = await Navigator.of(context).push<TeacherDirectoryEntity>(
                MaterialPageRoute(
                  builder: (_) => AddTeacherPage(
                    initialTeacher: teacher,
                    isEditMode: true,
                  ),
                ),
              );
              if (updated != null && mounted) {
                _bloc.add(UpdateTeacherEvent(updated));
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
                final bytes = await TeacherPdfGenerator.generateFacultyDossierPdf(teacher);
                await Printing.layoutPdf(
                  onLayout: (_) async => bytes,
                  name: 'Faculty_Dossier_${teacher.staffCode}_$cleanName',
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

  Future<void> _openAddTeacherScreen() async {
    final created = await Navigator.of(context).push<TeacherDirectoryEntity>(
      MaterialPageRoute(builder: (_) => const AddTeacherPage()),
    );
    if (created != null && mounted) {
      _bloc.add(CreateTeacherEvent(created));
    }
  }

  Future<void> _openEditTeacherScreen(TeacherDirectoryEntity teacher) async {
    final updated = await Navigator.of(context).push<TeacherDirectoryEntity>(
      MaterialPageRoute(
        builder: (_) => AddTeacherPage(
          initialTeacher: teacher,
          isEditMode: true,
        ),
      ),
    );
    if (updated != null && mounted) {
      _bloc.add(UpdateTeacherEvent(updated));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                // 1. Executive Top Header with Add Staff Action
                ExecutiveTopHeader(
                  icon: Icons.groups_rounded,
                  title: 'All Teachers & Staff',
                  subtitle: 'Faculty directory & academic portfolios',
                  onIconTap: () => Navigator.of(context).maybePop(),
                  trailing: InkWell(
                    onTap: _openAddTeacherScreen,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldPrimary, AppColors.goldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_rounded, size: 15, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Add Staff',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Main Scrollable Content with RefreshIndicator
                Expanded(
                  child: BlocBuilder<TeacherDirectoryBloc, TeacherDirectoryState>(
                    builder: (context, state) {
                      if (state is TeacherDirectoryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                          ),
                        );
                      }

                      if (state is TeacherDirectoryError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.statusAbsent),
                              const SizedBox(height: 10),
                              Text(
                                state.message,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _bloc.add(const RefreshTeacherDirectoryEvent()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is TeacherDirectoryLoaded) {
                        return RefreshIndicator(
                          color: AppColors.goldPrimary,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          onRefresh: () async {
                            _bloc.add(const RefreshTeacherDirectoryEvent());
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                            padding: const EdgeInsets.only(top: 8, bottom: 32),
                            children: [
                              // KPI Carousel Cards
                              StaffKPICarousel(stats: state.stats),
                              const SizedBox(height: 12),

                              // Search & Multi-Filters Bar (100% Student-Style Frosted Glass Bar)
                              StaffSearchFilterBar(
                                searchController: _searchController,
                                onSearchChanged: (q) => _bloc.add(SearchTeachersEvent(q)),
                                selectedStatus: state.selectedStatus,
                                onStatusSelected: (s) => _bloc.add(FilterTeachersEvent(status: s)),
                                selectedDutyMode: state.selectedDutyMode,
                                onDutyModeSelected: (m) => _bloc.add(FilterTeachersEvent(dutyMode: m)),
                                selectedDesignation: state.selectedDesignation,
                                onDesignationSelected: (d) => _bloc.add(FilterTeachersEvent(designation: d)),
                                totalMatches: state.filteredTeachers.length,
                              ),
                              const SizedBox(height: 12),

                              // Records Header Label with Count & Swipe Indicator (Mirroring Student Directory)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'STAFF DIRECTORY',
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
                                            '${state.filteredTeachers.length} Found',
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

                              // Faculty Data Table (Liquid Crystal Glass Horizontal Table)
                              StaffDirectoryTable(
                                teachers: state.filteredTeachers,
                                onTeacherTap: _openFacultyDossierPdf,
                                onEditTeacher: _openEditTeacherScreen,
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
