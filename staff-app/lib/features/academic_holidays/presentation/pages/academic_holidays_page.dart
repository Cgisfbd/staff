import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/academic_holidays/presentation/bloc/academic_holidays_bloc.dart';
import 'package:staff_app/features/academic_holidays/presentation/bloc/academic_holidays_event.dart';
import 'package:staff_app/features/academic_holidays/presentation/bloc/academic_holidays_state.dart';
import 'package:staff_app/features/academic_holidays/presentation/widgets/delete_holiday_dialog.dart';
import 'package:staff_app/features/academic_holidays/presentation/widgets/holiday_card.dart';
import 'package:staff_app/features/academic_holidays/presentation/widgets/holiday_category_filter_bar.dart';
import 'package:staff_app/features/academic_holidays/presentation/widgets/holiday_form_sheet.dart';
import 'package:staff_app/features/academic_holidays/presentation/widgets/holiday_search_bar.dart';
import 'package:staff_app/features/academic_holidays/presentation/widgets/holiday_summary_banner.dart';

class AcademicHolidaysPage extends StatelessWidget {
  const AcademicHolidaysPage({super.key, this.academicYearId});

  final String? academicYearId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AcademicHolidaysBloc>(
      create: (_) => sl<AcademicHolidaysBloc>()
        ..add(LoadHolidaysEvent(academicYearId: academicYearId)),
      child: const _AcademicHolidaysView(),
    );
  }
}

class _AcademicHolidaysView extends StatelessWidget {
  const _AcademicHolidaysView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AcademicHolidaysBloc, AcademicHolidaysState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.actionMessage != current.actionMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == AcademicHolidaysStatus.success && state.actionMessage != null) {
          AppSnackBar.showSuccess(context, state.actionMessage!);
        } else if (state.status == AcademicHolidaysStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final filteredList = state.filteredHolidays;

        return Scaffold(
          body: AppBackground(
            useSafeArea: false,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExecutiveTopHeader(
                    icon: Icons.arrow_back_rounded,
                    title: 'Holidays Calendar',
                    subtitle: state.academicYearName ?? 'Session holidays & vacation breaks',
                    onIconTap: () => Navigator.of(context).pop(),
                  ),

                  // Fixed Filter & Control Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        // Search Bar
                        HolidaySearchBar(
                          searchQuery: state.searchQuery,
                          onQueryChanged: (query) => context
                              .read<AcademicHolidaysBloc>()
                              .add(SearchQueryChangedEvent(query)),
                        ),

                        const SizedBox(height: 8),

                        // Categories Horizontal Filter Bar
                        HolidayCategoryFilterBar(
                          selectedCategory: state.selectedCategory,
                          allCount: state.allCount,
                          religiousCount: state.religiousCount,
                          nationalCount: state.nationalCount,
                          institutionalCount: state.institutionalCount,
                          onSelectCategory: (cat) => context
                              .read<AcademicHolidaysBloc>()
                              .add(FilterCategoryEvent(cat)),
                        ),

                        const SizedBox(height: 8),

                        // Summary Statistics Banner
                        HolidaySummaryBanner(
                          filteredCount: filteredList.length,
                          totalCount: state.allCount,
                          totalDaysOff: state.totalDaysOff,
                        ),
                      ],
                    ),
                  ),

                  // Scrollable List of Holidays
                  Expanded(
                    child: filteredList.isEmpty
                        ? _buildEmptyState(context, isDark)
                        : ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final holiday = filteredList[index];
                              return HolidayCard(
                                holiday: holiday,
                                index: index + 1,
                                onEdit: () {
                                  HolidayFormSheet.show(
                                    context,
                                    holidayToEdit: holiday,
                                    onSave: (updated) => context
                                        .read<AcademicHolidaysBloc>()
                                        .add(UpdateHolidayEvent(id: holiday.id, holiday: updated)),
                                  );
                                },
                                onDelete: () {
                                  DeleteHolidayDialog.show(
                                    context,
                                    holidayId: holiday.id,
                                    holidayTitle: holiday.titleEn.isNotEmpty
                                        ? holiday.titleEn
                                        : 'Academic Holiday',
                                    onConfirmDelete: (pin) => context
                                        .read<AcademicHolidaysBloc>()
                                        .add(DeleteHolidayEvent(id: holiday.id, pin: pin)),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              HolidayFormSheet.show(
                context,
                onSave: (newHoliday) => context
                    .read<AcademicHolidaysBloc>()
                    .add(CreateHolidayEvent(newHoliday)),
              );
            },
            backgroundColor: AppColors.goldPrimary,
            foregroundColor: Colors.white,
            elevation: 3,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Add Holiday',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 38,
                color: AppColors.goldPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Holidays Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule a holiday using the "Add Holiday" button below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
