import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/executive_top_header.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_bloc.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_event.dart';
import 'package:staff_app/features/academic_sessions/presentation/bloc/academic_session_state.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/academic_session_card.dart';
import 'package:staff_app/features/academic_sessions/presentation/widgets/create_session_sheet.dart';

class AcademicSessionsPage extends StatelessWidget {
  const AcademicSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AcademicSessionBloc>()..add(const LoadAcademicSessionsEvent()),
      child: const _AcademicSessionsView(),
    );
  }
}

class _AcademicSessionsView extends StatefulWidget {
  const _AcademicSessionsView();

  @override
  State<_AcademicSessionsView> createState() => _AcademicSessionsViewState();
}

class _AcademicSessionsViewState extends State<_AcademicSessionsView> {
  String _userRole = 'STAFF';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final profileStr = await sl<SecureStorageService>().getUserProfile();
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _userRole = data['role']?.toString() ?? 'STAFF';
          });
        }
      }
    } catch (_) {}
  }

  bool get _isAdmin => _userRole == 'SUPER_ADMIN' || _userRole == 'ADMIN';

  void _handleCreateSessionTap(BuildContext context, AcademicSessionLoaded state) {
    final nextInfo = state.nextSessionInfo;
    if (nextInfo != null && !nextInfo.canCreate) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextInfo.message ?? 'Please lock the active session before initializing a new one.',
          ),
          backgroundColor: const Color(0xFFF43F5E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    CreateSessionSheet.show(context, suggestedYear: nextInfo?.nextYear);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // Executive Header
            BlocBuilder<AcademicSessionBloc, AcademicSessionState>(
              builder: (context, state) {
                return ExecutiveTopHeader(
                  icon: Icons.date_range_rounded,
                  title: 'Academic Sessions',
                  subtitle: 'Active calendar, hierarchy & fiscal cycle',
                  onIconTap: () => context.pop(),
                  trailing: _isAdmin
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: state is AcademicSessionLoaded
                                ? () => _handleCreateSessionTap(context, state)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.goldDark, AppColors.goldPrimary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
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
                                  Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'NEW SESSION',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),

            // Content Area
            Expanded(
              child: BlocConsumer<AcademicSessionBloc, AcademicSessionState>(
                listener: (context, state) {
                  if (state is AcademicSessionLoaded && state.actionSuccessMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.actionSuccessMessage!),
                        backgroundColor: const Color(0xFF059669),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AcademicSessionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2),
                    );
                  }

                  if (state is AcademicSessionError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 42, color: Color(0xFFF43F5E)),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<AcademicSessionBloc>()
                                  .add(const LoadAcademicSessionsEvent()),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldPrimary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is AcademicSessionLoaded) {
                    final sessions = state.sessions;
                    final activeSession = state.activeSession;

                    return RefreshIndicator(
                      color: AppColors.goldPrimary,
                      onRefresh: () async {
                        context.read<AcademicSessionBloc>().add(const LoadAcademicSessionsEvent());
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                        children: [
                          // 1. Overview Metric Bar
                          _buildSummaryBar(context, sessions, isDark),
                          const SizedBox(height: 12),

                          // 2. Active Session Hero Banner
                          if (activeSession != null) ...[
                            _buildActiveSessionHero(context, activeSession, isDark),
                            const SizedBox(height: 14),
                          ],

                          // 3. Sessions List Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ALL ACADEMIC SESSIONS (${sessions.length})',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                ),
                              ),
                              Text(
                                'Tap to inspect details',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 4. List of Cards
                          ...sessions.map((session) {
                            final isExpanded = state.expandedSessionId == session.id;
                            return AcademicSessionCard(
                              key: ValueKey(session.id),
                              session: session,
                              isExpanded: isExpanded,
                              isAdmin: _isAdmin,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                context
                                    .read<AcademicSessionBloc>()
                                    .add(ToggleExpandSessionEvent(session.id));
                              },
                            );
                          }),
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
    );
  }

  Widget _buildSummaryBar(BuildContext context, List<dynamic> sessions, bool isDark) {
    final activeCount = sessions.where((s) => s.isActive == true).length;
    final lockedCount = sessions.where((s) => s.isLocked == true).length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.38 : 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.goldPrimary.withValues(alpha: 0.28),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryPill(
                  label: 'Total Sessions',
                  value: '${sessions.length}',
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.goldPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: (isDark ? Colors.white : AppColors.goldPrimary).withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildSummaryPill(
                  label: 'Active Calendar',
                  value: '$activeCount Live',
                  icon: Icons.bolt_rounded,
                  color: AppColors.emeraldLight,
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: (isDark ? Colors.white : AppColors.goldPrimary).withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildSummaryPill(
                  label: 'Fiscal Locked',
                  value: '$lockedCount Closed',
                  icon: Icons.lock_outline_rounded,
                  color: AppColors.goldChampagne,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionHero(
    BuildContext context,
    dynamic session,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.40 : 0.90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.goldPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ACTIVE CALENDAR',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.fiber_manual_record_rounded, size: 5, color: AppColors.emeraldLight),
                          const SizedBox(width: 3),
                          const Text(
                            'Live IST',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emeraldLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Academic Session ${session.yearName}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textLightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: isDark ? 0.35 : 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${session.progress}% Elapsed',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
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
