import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/utils/formatters.dart';

/// Amazon-Style Docked Liquid Crystal Glass Top Header (< 195 lines).
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.username,
    required this.role,
    this.instituteName = 'TaleemOne ERP',
    this.unreadNotificationsCount = 2,
    this.locationIp = '123.45.45.89',
    this.wifiIp = '192.168.1.35',
    this.isLocationVerified = true,
    this.isWifiVerified = true,
    this.onNotificationTap,
    this.onSearchTap,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onVerifyTap,
  });

  final String username;
  final String role;
  final String instituteName;
  final int unreadNotificationsCount;
  final String locationIp;
  final String wifiIp;
  final bool isLocationVerified;
  final bool isWifiVerified;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onVerifyTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDateWithDay = AppFormatters.formatDateWithDay(DateTime.now());
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xEB131720), const Color(0xD90F1117)]
                    : [Colors.white.withValues(alpha: 0.90), const Color(0xFFFAF9F6).withValues(alpha: 0.78)],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppColors.goldPrimary.withValues(alpha: 0.25)
                      : AppColors.goldPrimary.withValues(alpha: 0.22),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Amazon Search Box & Notification Bell
                Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight > 0 ? statusBarHeight + 8 : 14,
                    bottom: 10,
                    left: 14,
                    right: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAmazonSearchBar(context, isDark),
                      ),
                      const SizedBox(width: 10),
                      _buildNotificationBell(isDark),
                    ],
                  ),
                ),

                // Bottom Row: Ultra-Premium Executive Identity & Telemetry Card
                _buildExecutiveCard(context, isDark, currentDateWithDay),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmazonSearchBar(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onSearchTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0x2EFFFFFF) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppColors.goldPrimary.withValues(alpha: 0.30)
                : AppColors.goldPrimary.withValues(alpha: 0.32),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 13),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? AppColors.goldChampagne : AppColors.goldPrimary,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                onTap: onSearchTap,
                onSubmitted: onSearchSubmitted,
                textInputAction: TextInputAction.search,
                cursorColor: AppColors.goldPrimary,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('search_hint'),
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBell(bool isDark) {
    return InkWell(
      onTap: onNotificationTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0x2EFFFFFF) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppColors.goldPrimary.withValues(alpha: 0.30)
                : AppColors.goldPrimary.withValues(alpha: 0.32),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 21,
              color: isDark ? AppColors.goldLight : AppColors.charcoalDark,
            ),
            if (unreadNotificationsCount > 0)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.rosePrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F1117) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Ultra-Luxury Executive Identity Card with Right-Shifted Badge & Telemetry Deck.
  Widget _buildExecutiveCard(BuildContext context, bool isDark, String dateStr) {
    final welcomeText = context.tr('welcome_to', params: {'institute': instituteName});

    final langCode = context.currentLanguageCode;
    final isRtl = context.isRtl;
    final displayUsername = switch (langCode) {
      'ur' => (username.toLowerCase().contains('ustad') || username.toLowerCase().contains('ahmed')
          ? 'استاذ احمد قاسمی'
          : (username == 'Staff Member' ? 'استاذِ محترم' : username)),
      'hi' => (username.toLowerCase().contains('ustad') || username.toLowerCase().contains('ahmed')
          ? 'उस्ताद अहमद क़ासिमी'
          : (username == 'Staff Member' ? 'सम्मानित शिक्षक' : username)),
      _ => username,
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0x381E293B),
                  const Color(0x1F0F172A),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  const Color(0xFFFBF8F3).withValues(alpha: 0.88),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.goldPrimary.withValues(alpha: 0.35)
              : AppColors.goldPrimary.withValues(alpha: 0.38),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF9E7B3B)).withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Avatar + Greeting & Name + Right-Shifted Role & Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Medallion with Live Active Pip
              _buildAvatarMedallion(isDark),
              const SizedBox(width: 10),

              // Middle Column: Institute Greeting + Staff Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 11.5,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            welcomeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayUsername,
                      style: TextStyle(
                        fontSize: isRtl ? 17.5 : 16.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        letterSpacing: isRtl ? 0 : -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Far Right: Role Badge (Top) + Date (Directly Below, Right Aligned)
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Role Badge (SUPER ADMIN / STAFF)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.goldPrimary.withValues(alpha: 0.25),
                                      AppColors.goldPrimary.withValues(alpha: 0.12),
                                    ]
                                  : [
                                      AppColors.goldPrimary.withValues(alpha: 0.20),
                                      AppColors.goldPrimary.withValues(alpha: 0.10),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.goldChampagne.withValues(alpha: 0.6)
                                  : AppColors.goldDark.withValues(alpha: 0.5),
                              width: 0.9,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                size: 10.5,
                                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLocalizedRole(context, role),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Date shifted below (Clean typography, Right-Aligned)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: isDark ? AppColors.goldChampagne : AppColors.goldPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.goldLight : AppColors.goldDark,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Delicate Gold Hairline Divider
          Container(
            margin: const EdgeInsets.only(top: 11, bottom: 9),
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldPrimary.withValues(alpha: isDark ? 0.30 : 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Bottom Section: Luxury Telemetry Dock (Location Geofence + Wi-Fi + Verify Action)
          _buildTelemetryDock(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAvatarMedallion(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF2A3447),
                      const Color(0xFF131A26),
                    ]
                  : [
                      const Color(0xFFFFFDF9),
                      const Color(0xFFEFE9DB),
                    ],
            ),
            border: Border.all(
              color: isDark ? AppColors.goldChampagne : AppColors.goldPrimary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'S',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
        ),
        // Active Live Session Pip
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.statusPresent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF131A26) : Colors.white,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.statusPresent.withValues(alpha: 0.7),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryDock(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.goldPrimary.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Geofence / Location Telemetry Pod
            _buildTelemetryPod(
              isDark: isDark,
              isVerified: isLocationVerified,
              tag: context.tr('telemetry_geofence'),
              value: locationIp,
              icon: Icons.location_on_rounded,
            ),

            // Vertical Micro-Divider
            _buildVerticalSeparator(isDark),

            // Campus Wi-Fi Telemetry Pod
            _buildTelemetryPod(
              isDark: isDark,
              isVerified: isWifiVerified,
              tag: context.tr('telemetry_campus_wifi'),
              value: wifiIp,
              icon: Icons.wifi_rounded,
            ),

            // Vertical Micro-Divider
            _buildVerticalSeparator(isDark),

            // Verify Action Button
            _buildVerifyButton(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryPod({
    required bool isDark,
    required bool isVerified,
    required String tag,
    required String value,
    required IconData icon,
  }) {
    final statusColor = isVerified ? AppColors.statusPresent : AppColors.statusAbsent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing Glow Indicator Dot
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.7),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        // Icon
        Icon(
          icon,
          size: 13.5,
          color: statusColor,
        ),
        const SizedBox(width: 5),
        // Tag & Value Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalSeparator(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 0.8,
      height: 22,
      color: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : AppColors.goldPrimary.withValues(alpha: 0.22),
    );
  }

  Widget _buildVerifyButton(BuildContext context, bool isDark) {
    final isAllVerified = isLocationVerified && isWifiVerified;
    final btnColor = isAllVerified ? AppColors.statusPresent : AppColors.statusAbsent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onVerifyTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      btnColor.withValues(alpha: 0.22),
                      btnColor.withValues(alpha: 0.10),
                    ]
                  : [
                      btnColor.withValues(alpha: 0.18),
                      btnColor.withValues(alpha: 0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: btnColor.withValues(alpha: 0.55),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: btnColor.withValues(alpha: 0.20),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAllVerified ? Icons.verified_rounded : Icons.sync_rounded,
                size: 13,
                color: btnColor,
              ),
              const SizedBox(width: 4),
              Text(
                isAllVerified ? context.tr('telemetry_verified') : context.tr('telemetry_verify'),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: btnColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedRole(BuildContext context, String role) {
    final clean = role.toUpperCase();
    if (clean.contains('SUPER')) {
      return context.tr('role_super_admin');
    } else if (clean.contains('ADMIN')) {
      return context.tr('role_admin');
    } else {
      return context.tr('role_staff');
    }
  }
}
