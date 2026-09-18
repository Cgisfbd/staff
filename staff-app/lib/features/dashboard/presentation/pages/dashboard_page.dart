import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/di/injection_container.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/router/route_names.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/features/dashboard/domain/models/occasion_banner.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_punch_card.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/occasion_banner_card.dart';
import 'package:staff_app/features/dashboard/presentation/widgets/teacher_attendance_card.dart';

/// Screen Orchestrator for Staff App Dashboard (< 120 lines).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _username = 'Staff Member';
  String _role = 'STAFF';
  String _instituteName = 'TaleemOne ERP';
  bool _isLocationVerified = true;
  bool _isWifiVerified = true;

  final List<OccasionBanner> _banners = const [
    OccasionBanner(
      id: 'banner_special_occasion',
      title: 'Mubarak & Academic Greetings',
      subtitle: 'Warm greetings from TaleemOne ERP to all staff and teachers. Institute session active.',
      imagePath: 'assets/images/banner.png',
      badge: 'SPECIAL OCCASION',
      isDismissible: false,
    ),
    OccasionBanner(
      id: 'banner_annual_convocation',
      title: 'Annual Academic Convocation',
      subtitle: 'Official circular regarding the upcoming annual convocation and student awards.',
      imagePath: 'assets/images/app_banner_rtl.png',
      badge: 'OFFICIAL NOTICE',
      isDismissible: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final secureStorage = sl<SecureStorageService>();
      final profileStr = await secureStorage.getUserProfile();
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _username = data['username']?.toString() ?? 'Staff Member';
            _role = data['role']?.toString() ?? 'STAFF';
            _instituteName = data['instituteName']?.toString() ??
                data['institute_name']?.toString() ??
                'TaleemOne ERP';
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useSafeArea: false,
        child: Column(
          children: [
            DashboardHeader(
              username: _username,
              role: _role,
              instituteName: _instituteName,
              isLocationVerified: _isLocationVerified,
              isWifiVerified: _isWifiVerified,
              onNotificationTap: () => context.push(RouteNames.notifications),
              onSearchTap: () => context.push(RouteNames.search),
              onSearchSubmitted: (_) => context.push(RouteNames.search),
              onVerifyTap: () {
                setState(() {
                  _isLocationVerified = !_isLocationVerified;
                  _isWifiVerified = !_isWifiVerified;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isLocationVerified
                          ? context.tr('telemetry_location_verified_msg')
                          : context.tr('telemetry_location_failed_msg'),
                    ),
                    backgroundColor: _isLocationVerified ? AppColors.statusPresent : AppColors.statusAbsent,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    OccasionBannerCard(
                      banners: _banners,
                    ),
                    const SizedBox(height: 14),
                    const DashboardPunchCard(),
                    const SizedBox(height: 14),
                    const TeacherAttendanceCard(),
                    const SizedBox(height: 16),
                    const DashboardQuickActions(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
