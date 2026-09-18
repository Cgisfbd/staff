import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/students/domain/entities/student_directory_entity.dart';

/// 100% Zero-Swipe Responsive KPI Deck mirroring ERP StudentKPICards (< 220 lines).
/// Renders all 7 metrics within the screen viewport with zero horizontal scrolling.
class StudentKPICarousel extends StatelessWidget {
  const StudentKPICarousel({
    super.key,
    required this.stats,
  });

  final StudentStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // Row 1: Primary Metrics (Total Enrolled & Active Now)
          Row(
            children: [
              Expanded(
                child: _buildPrimaryCard(
                  title: 'Total Enrolled',
                  count: stats.totalActive,
                  badgeText: 'All Records',
                  icon: Icons.people_alt_rounded,
                  gradientColors: const [AppColors.goldPrimary, AppColors.goldDark],
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryCard(
                  title: 'Active Now',
                  count: stats.activeCount,
                  badgeText: 'Active',
                  icon: Icons.how_to_reg_rounded,
                  gradientColors: const [AppColors.statusPresent, Color(0xFF047857)],
                  isDark: isDark,
                  isPulsing: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Secondary Status Metrics (Dropout & Graduated)
          Row(
            children: [
              Expanded(
                child: _buildSecondaryCard(
                  title: 'Dropout',
                  count: stats.dropoutCount,
                  badgeText: 'Left',
                  icon: Icons.person_off_rounded,
                  color: AppColors.statusAbsent,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryCard(
                  title: 'Graduate',
                  count: stats.graduatedCount,
                  badgeText: 'Alumni',
                  icon: Icons.school_rounded,
                  color: AppColors.statusLeave,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Study Mode & RFID Chips (Offline, Online, RFID) - Pure Gold & Emerald harmony
          Row(
            children: [
              Expanded(
                child: _buildMicroChip(
                  label: 'Offline',
                  count: stats.offlineCount,
                  icon: Icons.apartment_rounded,
                  color: AppColors.goldDark,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMicroChip(
                  label: 'Online',
                  count: stats.onlineCount,
                  icon: Icons.public_rounded,
                  color: AppColors.goldPrimary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMicroChip(
                  label: 'RFID',
                  count: stats.rfidLinked,
                  icon: Icons.contactless_rounded,
                  color: AppColors.statusPresent,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCard({
    required String title,
    required int count,
    required String badgeText,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isDark,
    bool isPulsing = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(alpha: isDark ? 0.38 : 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.75),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: gradientColors.first,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 13, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: gradientColors.first.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPulsing) ...[
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 3),
                          ],
                          Flexible(
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: gradientColors.first,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCard({
    required String title,
    required int count,
    required String badgeText,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x281E293B) : Colors.white).withValues(alpha: isDark ? 0.32 : 0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.white.withValues(alpha: 0.65),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 11, color: color),
                    const SizedBox(width: 3),
                    Text(
                      badgeText,
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicroChip({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x281E293B) : Colors.white).withValues(alpha: isDark ? 0.32 : 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.white.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $count',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
