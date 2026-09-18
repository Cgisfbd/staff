import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/staff/domain/entities/teacher_directory_entity.dart';

/// 100% Zero-Swipe Responsive KPI Deck for Faculty & Staff.
/// Exactly mirrors StudentKPICarousel with Liquid Crystal Glassmorphism,
/// zero truncation ("...") issues, and Champagne Gold & Emerald styling.
class StaffKPICarousel extends StatelessWidget {
  const StaffKPICarousel({
    super.key,
    required this.stats,
  });

  final TeacherStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // Row 1: Primary Metrics (Total Faculty & Active Now)
          Row(
            children: [
              Expanded(
                child: _buildPrimaryCard(
                  title: 'Total Faculty',
                  count: stats.totalFaculty,
                  badgeText: 'All Staff',
                  icon: Icons.groups_rounded,
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

          // Row 2: Duty Modes Chips (Hostel, Day Duty, Online) — Crisp labels, zero ellipsis
          Row(
            children: [
              Expanded(
                child: _buildMicroChip(
                  label: 'Hostel',
                  count: stats.hostelResidentCount,
                  icon: Icons.hotel_rounded,
                  color: AppColors.goldDark,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMicroChip(
                  label: 'Day Duty',
                  count: stats.dayDutyCount,
                  icon: Icons.directions_walk_rounded,
                  color: AppColors.goldPrimary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMicroChip(
                  label: 'Online',
                  count: stats.onlineCount,
                  icon: Icons.laptop_chromebook_rounded,
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
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.38 : 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.75),
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
                        fontSize: 10.5,
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: gradientColors.first,
                                ),
                                maxLines: 1,
                              ),
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

  Widget _buildMicroChip({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0x331E293B) : Colors.white)
                .withValues(alpha: isDark ? 0.35 : 0.30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
