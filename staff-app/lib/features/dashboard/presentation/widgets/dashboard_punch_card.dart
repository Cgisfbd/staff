import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/settings/presentation/cubit/app_lock_cubit.dart';
import 'package:staff_app/features/settings/presentation/widgets/set_local_pin_dialog.dart';
import 'package:staff_app/features/settings/presentation/widgets/verify_local_pin_dialog.dart';

/// Ultra-Refined Campus Punch In / Punch Out Card with Mandatory 6-Digit PIN Verification (< 260 lines).
class DashboardPunchCard extends StatefulWidget {
  const DashboardPunchCard({super.key});

  @override
  State<DashboardPunchCard> createState() => _DashboardPunchCardState();
}

class _DashboardPunchCardState extends State<DashboardPunchCard> {
  static const String _keyDate = 'punch_record_date';
  static const String _keyIn = 'punch_is_in';
  static const String _keyOut = 'punch_is_out';
  static const String _keyInTime = 'punch_in_timestamp';
  static const String _keyOutTime = 'punch_out_timestamp';

  bool _isPunchedIn = false;
  bool _isPunchedOut = false;
  String? _punchInTime;
  String? _punchOutTime;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedPunchState();
  }

  Future<void> _loadPersistedPunchState() async {
    try {
      final storage = sl<SecureStorageService>();
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final savedDate = await storage.getString(_keyDate);

      if (savedDate == todayStr) {
        final inVal = await storage.getString(_keyIn);
        final outVal = await storage.getString(_keyOut);
        final inTime = await storage.getString(_keyInTime);
        final outTime = await storage.getString(_keyOutTime);

        if (mounted) {
          setState(() {
            _isPunchedIn = inVal == 'true';
            _isPunchedOut = outVal == 'true';
            _punchInTime = (inTime != null && inTime.isNotEmpty) ? inTime : null;
            _punchOutTime = (outTime != null && outTime.isNotEmpty) ? outTime : null;
            _isInitialized = true;
          });
        }
      } else {
        // Reset for new academic day
        await storage.setString(_keyDate, todayStr);
        await storage.setString(_keyIn, 'false');
        await storage.setString(_keyOut, 'false');
        await storage.setString(_keyInTime, '');
        await storage.setString(_keyOutTime, '');

        if (mounted) {
          setState(() {
            _isPunchedIn = false;
            _isPunchedOut = false;
            _punchInTime = null;
            _punchOutTime = null;
            _isInitialized = true;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  Future<void> _handlePunchAction({required bool isPunchIn}) async {
    unawaited(HapticFeedback.mediumImpact());

    final lockCubit = context.read<AppLockCubit>();
    if (!lockCubit.state.hasLocalPin) {
      final setupSuccess = await SetLocalPinDialog.show(context, isChangingExisting: false);
      if (setupSuccess != true || !mounted) return;
    }

    final verified = await VerifyLocalPinDialog.show(
      context,
      title: isPunchIn ? context.tr('punch_verify_in_title') : context.tr('punch_verify_out_title'),
      subtitle: isPunchIn
          ? context.tr('punch_pin_prompt_in')
          : context.tr('punch_pin_prompt_out'),
    );

    if (verified != true || !mounted) return;

    final nowFormatted = AppFormatters.formatTime(DateTime.now());
    final storage = sl<SecureStorageService>();
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (isPunchIn) {
      setState(() {
        _isPunchedIn = true;
        _isPunchedOut = false;
        _punchInTime = nowFormatted;
      });
      await storage.setString(_keyDate, todayStr);
      await storage.setString(_keyIn, 'true');
      await storage.setString(_keyOut, 'false');
      await storage.setString(_keyInTime, nowFormatted);

      if (mounted) {
        AppSnackBar.showSuccess(context, context.tr('punch_in_success', params: {'time': nowFormatted}));
      }
    } else {
      setState(() {
        _isPunchedIn = false;
        _isPunchedOut = true;
        _punchOutTime = nowFormatted;
      });
      await storage.setString(_keyDate, todayStr);
      await storage.setString(_keyIn, 'false');
      await storage.setString(_keyOut, 'true');
      await storage.setString(_keyOutTime, nowFormatted);

      if (mounted) {
        AppSnackBar.showSuccess(context, context.tr('punch_out_success', params: {'time': nowFormatted}));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(height: 120);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPunchIn = !_isPunchedIn && !_isPunchedOut;
    final canPunchOut = _isPunchedIn && !_isPunchedOut;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldPrimary.withValues(alpha: 0.25),
                            AppColors.goldPrimary.withValues(alpha: 0.12),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.45),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.fingerprint_rounded,
                        color: AppColors.goldPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('punch_station_title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            AppFormatters.formatDateWithDay(DateTime.now()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(isDark),
                  ],
                ),

                // Active Timestamps Telemetry Row (No ellipsis truncation)
                if (_punchInTime != null || _punchOutTime != null) ...[
                  const SizedBox(height: 11),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0x1F000000),
                        width: 0.8,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_punchInTime != null) ...[
                            const Icon(Icons.login_rounded, size: 13, color: AppColors.statusPresent),
                            const SizedBox(width: 5),
                            Text(
                              context.tr('punch_in_prefix', params: {'time': _punchInTime!}),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.emeraldLight : AppColors.emeraldDark,
                              ),
                            ),
                          ],
                          if (_punchInTime != null && _punchOutTime != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white30 : Colors.black26,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (_punchOutTime != null) ...[
                            const Icon(Icons.logout_rounded, size: 13, color: AppColors.statusAbsent),
                            const SizedBox(width: 5),
                            Text(
                              context.tr('punch_out_prefix', params: {'time': _punchOutTime!}),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.rosePrimary : const Color(0xFFBE123C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 13),

                // Two Mutually Exclusive Refined Action Buttons
                Row(
                  children: [
                    // PUNCH IN BUTTON
                    Expanded(
                      child: _buildRefinedButton(
                        context: context,
                        label: context.tr('punch_in_btn'),
                        subtitle: _isPunchedIn
                            ? context.tr('punch_in_prefix', params: {'time': _punchInTime!})
                            : context.tr('punch_check_in_sub'),
                        icon: _isPunchedIn ? Icons.check_circle_rounded : Icons.login_rounded,
                        isActive: canPunchIn,
                        isDark: isDark,
                        activeGradient: const [AppColors.statusPresent, Color(0xFF10B981)],
                        activeBorderColor: const Color(0xFF34D399),
                        activeShadowColor: AppColors.statusPresent,
                        onTap: canPunchIn
                            ? () => _handlePunchAction(isPunchIn: true)
                            : () {
                                if (_isPunchedIn) {
                                  AppSnackBar.showSuccess(
                                    context,
                                    context.tr('punch_already_in', params: {'time': _punchInTime!}),
                                  );
                                } else if (_isPunchedOut) {
                                  AppSnackBar.showSuccess(context, context.tr('punch_shift_completed'));
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // PUNCH OUT BUTTON
                    Expanded(
                      child: _buildRefinedButton(
                        context: context,
                        label: context.tr('punch_out_btn'),
                        subtitle: _isPunchedOut
                            ? context.tr('punch_out_prefix', params: {'time': _punchOutTime!})
                            : context.tr('punch_check_out_sub'),
                        icon: _isPunchedOut ? Icons.check_circle_rounded : Icons.logout_rounded,
                        isActive: canPunchOut,
                        isDark: isDark,
                        activeGradient: const [AppColors.statusAbsent, Color(0xFFF43F5E)],
                        activeBorderColor: const Color(0xFFFB7185),
                        activeShadowColor: AppColors.statusAbsent,
                        onTap: canPunchOut
                            ? () => _handlePunchAction(isPunchIn: false)
                            : () {
                                if (!_isPunchedIn && !_isPunchedOut) {
                                  AppSnackBar.showError(context, context.tr('punch_in_first_warning'));
                                } else if (_isPunchedOut) {
                                  AppSnackBar.showSuccess(
                                    context,
                                    context.tr('punch_already_in', params: {'time': _punchOutTime!}),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
    if (_isPunchedIn) {
      return _chipContainer(
        text: context.tr('punch_status_on_campus'),
        color: AppColors.statusPresent,
        isPulsing: true,
      );
    } else if (_isPunchedOut) {
      return _chipContainer(
        text: context.tr('punch_status_checked_out'),
        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
        isPulsing: false,
      );
    } else {
      return _chipContainer(
        text: context.tr('punch_status_not_punched'),
        color: AppColors.statusLeave,
        isPulsing: false,
      );
    }
  }

  Widget _chipContainer({
    required String text,
    required Color color,
    required bool isPulsing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isPulsing
                  ? [BoxShadow(color: color.withValues(alpha: 0.65), blurRadius: 5, spreadRadius: 0.5)]
                  : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  /// High-End Tactile Action Button with Frosted Crystal Inactive Styling (Zero Ghosting/Washing out).
  Widget _buildRefinedButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required List<Color> activeGradient,
    required Color activeBorderColor,
    required Color activeShadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isActive
            ? LinearGradient(
                colors: activeGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        // Elegant Frosted Glass for Inactive State (Never washed-out grey smudge)
        color: isActive
            ? null
            : (isDark ? const Color(0x2B1E293B) : const Color(0x52F1F5F9)),
        border: Border.all(
          color: isActive
              ? activeBorderColor.withValues(alpha: 0.70)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08)),
          width: 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeShadowColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: isActive
              ? Colors.white24
              : AppColors.goldPrimary.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.85)
                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
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
