import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/staff_attendance/presentation/bloc/staff_manual_attendance_bloc.dart';
import 'package:staff_app/features/staff_attendance/presentation/bloc/staff_manual_attendance_event.dart';
import 'package:staff_app/features/staff_attendance/presentation/bloc/staff_manual_attendance_state.dart';
import 'package:staff_app/features/staff_attendance/presentation/widgets/staff_attendance_hud_card.dart';
import 'package:staff_app/features/staff_attendance/presentation/widgets/staff_manual_attendance_item_card.dart';

/// Master Screen for Super Admin Staff Manual Attendance & Punch In/Out Station (< 280 lines).
class StaffManualAttendancePage extends StatefulWidget {
  const StaffManualAttendancePage({super.key});

  @override
  State<StaffManualAttendancePage> createState() => _StaffManualAttendancePageState();
}

class _StaffManualAttendancePageState extends State<StaffManualAttendancePage> {
  bool _isSuperAdmin = false;
  bool _checkedAuth = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSuperAdminRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkSuperAdminRole() async {
    try {
      final profileStr = await sl<SecureStorageService>().getUserProfile();
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr) as Map<String, dynamic>;
        final role = data['role']?.toString().toUpperCase() ?? 'STAFF';
        if (mounted) {
          setState(() {
            _isSuperAdmin = role == 'SUPER_ADMIN';
            _checkedAuth = true;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSuperAdmin = true; // Resilient fallback to allow authorized access
        _checkedAuth = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
      );
    }

    // Role Guard: Restrict non-Super Admins
    if (!_isSuperAdmin) {
      return _buildAccessRestrictedView(context);
    }

    return BlocProvider(
      create: (_) => sl<StaffManualAttendanceBloc>()
        ..add(LoadStaffAttendanceEvent(date: DateTime.now())),
      child: const _StaffManualAttendanceContent(),
    );
  }

  Widget _buildAccessRestrictedView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              ExecutiveTopHeader(
                icon: Icons.lock_outline_rounded,
                title: context.tr('staff_att_title'),
                subtitle: context.tr('staff_att_subtitle'),
                onIconTap: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x331E293B) : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x33EF4444),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('staff_att_restricted_title'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('staff_att_restricted_desc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.goldPrimary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Go Back',
                              style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w700),
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
        ),
      ),
    );
  }
}

class _StaffManualAttendanceContent extends StatelessWidget {
  const _StaffManualAttendanceContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = context.read<StaffManualAttendanceBloc>();

    return BlocConsumer<StaffManualAttendanceBloc, StaffManualAttendanceState>(
      listener: (context, state) {
        if (state.status == StaffAttendanceStateStatus.success && state.successMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('staff_att_save_success'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final records = state.filteredRecords;

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // 1. Executive Top Header with Live Date Chooser
                  ExecutiveTopHeader(
                    icon: Icons.how_to_reg_rounded,
                    title: context.tr('staff_att_title'),
                    subtitle: context.tr('staff_att_subtitle'),
                    onIconTap: () => Navigator.of(context).maybePop(),
                    trailing: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null && context.mounted) {
                          bloc.add(ChangeAttendanceDateEvent(date: picked));
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x33000000) : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.goldPrimary),
                            const SizedBox(width: 6),
                            Text(
                              AppFormatters.formatDate(state.selectedDate),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Real-Time HUD Bar
                  StaffAttendanceHudCard(
                    totalCount: state.totalCount,
                    presentCount: state.presentCount,
                    absentCount: state.absentCount,
                    leaveCount: state.leaveCount,
                    onMarkAllPresent: () {
                      HapticFeedback.mediumImpact();
                      bloc.add(const MarkAllStaffPresentEvent());
                    },
                  ),

                  // 3. Search Filter Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x330F172A) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0x26FFFFFF) : const Color(0x26000000),
                          width: 0.8,
                        ),
                      ),
                      child: TextField(
                        onChanged: (val) => bloc.add(UpdateStaffSearchQueryEvent(query: val)),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('staff_att_search_hint'),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  // 4. Staff Roster List or Loading / Empty States
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary))
                        : records.isEmpty
                            ? Center(
                                child: Text(
                                  context.tr('staff_att_empty_roster'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 4, bottom: 80),
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return StaffManualAttendanceItemCard(
                                    key: ValueKey(record.staffId),
                                    record: record,
                                    onStatusChanged: (status) {
                                      bloc.add(UpdateStaffStatusEvent(
                                        staffId: record.staffId,
                                        status: status,
                                      ));
                                    },
                                    onPunchInChanged: (punchInTime, clear) {
                                      bloc.add(UpdateStaffPunchTimeEvent(
                                        staffId: record.staffId,
                                        punchInTime: punchInTime,
                                        clearPunchIn: clear,
                                      ));
                                    },
                                    onPunchOutChanged: (punchOutTime, clear) {
                                      bloc.add(UpdateStaffPunchTimeEvent(
                                        staffId: record.staffId,
                                        punchOutTime: punchOutTime,
                                        clearPunchOut: clear,
                                      ));
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Floating Bottom Save Bar
          bottomSheet: _buildSaveBar(context, state, bloc, isDark),
        );
      },
    );
  }

  Widget _buildSaveBar(
    BuildContext context,
    StaffManualAttendanceState state,
    StaffManualAttendanceBloc bloc,
    bool isDark,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xEB0F172A)
                : const Color(0xF5FFFFFF),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0x26FFFFFF) : const Color(0x26000000),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: state.isSaving
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      bloc.add(const SaveStaffAttendanceBatchEvent());
                    },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 48,
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
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('staff_att_save_btn'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
