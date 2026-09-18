import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff/domain/entities/staff_duty_entity.dart';
import 'package:staff_app/features/staff/presentation/bloc/staff_duty_bloc.dart';
import 'package:staff_app/features/staff/presentation/pages/assign_duty_page.dart';
import 'package:staff_app/features/staff/presentation/widgets/duty_allocations_table.dart';
import 'package:staff_app/features/staff/presentation/widgets/duty_search_bar.dart';
import 'package:staff_app/features/staff/presentation/widgets/duty_summary_deck.dart';

/// Master Screen for Faculty Duty Allocations Hub (Classes & Books).
class DutyAllocationsPage extends StatefulWidget {
  const DutyAllocationsPage({super.key});

  @override
  State<DutyAllocationsPage> createState() => _DutyAllocationsPageState();
}

class _DutyAllocationsPageState extends State<DutyAllocationsPage> {
  late final StaffDutyBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<StaffDutyBloc>()..add(const LoadStaffDutiesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openAssignDutyScreen(StaffDutyEntity duty) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AssignDutyPage(
          duty: duty,
          onSave: ({required assignedClasses, required assignedBooks}) async {
            _bloc.add(SaveStaffDutyEvent(
              facultyId: duty.facultyId,
              assignedClasses: assignedClasses,
              assignedBooks: assignedBooks,
            ));
          },
        ),
      ),
    );
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
                // 1. Executive Top Header
                ExecutiveTopHeader(
                  icon: Icons.assignment_ind_rounded,
                  title: 'Duty Allocations',
                  subtitle: 'Academic class & kitab allocations',
                  onIconTap: () => Navigator.of(context).maybePop(),
                ),

                // 2. Main Scrollable Roster
                Expanded(
                  child: BlocConsumer<StaffDutyBloc, StaffDutyState>(
                    listener: (context, state) {
                      if (state is StaffDutyLoaded && state.saveSuccessMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.saveSuccessMessage!,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is StaffDutyLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                          ),
                        );
                      }

                      if (state is StaffDutyError) {
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
                                onPressed: () => _bloc.add(const RefreshStaffDutiesEvent()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is StaffDutyLoaded) {
                        return RefreshIndicator(
                          color: AppColors.goldPrimary,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          onRefresh: () async {
                            _bloc.add(const RefreshStaffDutiesEvent());
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.only(top: 8, bottom: 32),
                            children: [
                              // KPI Summary Deck
                              DutySummaryDeck(stats: state.stats),
                              const SizedBox(height: 12),

                              // Search & Status Filters Bar
                              DutySearchBar(
                                searchController: _searchController,
                                onSearchChanged: (q) => _bloc.add(SearchStaffDutiesEvent(q)),
                                selectedStatus: state.selectedStatus,
                                onStatusSelected: (s) => _bloc.add(FilterStaffDutiesEvent(status: s)),
                              ),
                              const SizedBox(height: 10),

                              // Duty Allocations Liquid Crystal Glass Data Table
                              DutyAllocationsTable(
                                duties: state.filteredDuties,
                                onAssignTap: _openAssignDutyScreen,
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
