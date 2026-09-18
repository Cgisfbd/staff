import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/daily_timings/presentation/bloc/daily_timings_bloc.dart';
import 'package:staff_app/features/daily_timings/presentation/bloc/daily_timings_event.dart';
import 'package:staff_app/features/daily_timings/presentation/bloc/daily_timings_state.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/periods_grid.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/timing_bottom_actions.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/timing_presets_bar.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/timing_sequence_banner.dart';
import 'package:staff_app/features/daily_timings/presentation/widgets/timing_stat_cards.dart';

class DailyTimingsPage extends StatelessWidget {
  const DailyTimingsPage({super.key, this.academicYearId});

  final String? academicYearId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DailyTimingsBloc>(
      create: (_) => sl<DailyTimingsBloc>()
        ..add(LoadScheduleTimingsEvent(academicYearId: academicYearId)),
      child: const _DailyTimingsView(),
    );
  }
}

class _DailyTimingsView extends StatelessWidget {
  const _DailyTimingsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<DailyTimingsBloc, DailyTimingsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == DailyTimingsStatus.saved) {
          AppSnackBar.showSuccess(context, 'Daily class schedule saved successfully!');
        } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
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
                    title: 'Daily Class Timings',
                    subtitle: state.academicYearName ?? 'Academic bell times, periods & recess',
                    onIconTap: () => Navigator.of(context).pop(),
                  ),

                  // 2. Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Feature Overview Banner
                          _buildHeaderBanner(context, isDark),

                          const SizedBox(height: 12),

                          // Minimalist Sequence Pill (Progression Overview)
                          TimingSequenceBanner(
                            timings: state.timings,
                            computation: state.computation,
                          ),

                          const SizedBox(height: 14),

                          // 4 Core Metrics Cards
                          TimingStatCards(
                            timings: state.timings,
                            computation: state.computation,
                            onAssemblyTimeChanged: (time) =>
                                context.read<DailyTimingsBloc>().add(UpdateAssemblyTimeEvent(time)),
                            onStartTimeChanged: (time) =>
                                context.read<DailyTimingsBloc>().add(UpdateStartTimeEvent(time)),
                            onLunchSlotChanged: (slot) =>
                                context.read<DailyTimingsBloc>().add(UpdateLunchSlotEvent(slot)),
                            onLunchDurationChanged: (mins) =>
                                context.read<DailyTimingsBloc>().add(UpdateLunchDurationEvent(mins)),
                          ),

                          const SizedBox(height: 14),

                          // Quick Presets Bar
                          TimingPresetsBar(
                            currentAssembly: state.timings.assemblyTime,
                            currentStart: state.timings.startTime,
                            onApplyPreset: (preset) {
                              context.read<DailyTimingsBloc>().add(
                                    ApplyPresetEvent(
                                      assembly: preset.assembly,
                                      start: preset.start,
                                      name: preset.name,
                                    ),
                                  );
                              AppSnackBar.showSuccess(context, 'Applied "${preset.name}" preset schedule.');
                            },
                          ),

                          const SizedBox(height: 16),

                          // 8 Periods Grid with dynamic lunch insertion
                          PeriodsGrid(
                            computation: state.computation,
                            onPeriodDurationChanged: (index, duration) =>
                                context.read<DailyTimingsBloc>().add(
                                      UpdatePeriodDurationEvent(
                                        index: index,
                                        durationMinutes: duration,
                                      ),
                                    ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom Action Bar
                  TimingBottomActions(
                    status: state.status,
                    isSavedRecently: state.isSavedRecently,
                    onReset: () {
                      context.read<DailyTimingsBloc>().add(const ResetTimingsEvent());
                      AppSnackBar.showSuccess(context, 'Schedule reset to standard 8:00 AM timings.');
                    },
                    onSave: () => context.read<DailyTimingsBloc>().add(const SaveScheduleTimingsEvent()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldPrimary, AppColors.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Schedule & Academic Timings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Assembly ingress, class start, lunch recess & dismissal.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black45,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
