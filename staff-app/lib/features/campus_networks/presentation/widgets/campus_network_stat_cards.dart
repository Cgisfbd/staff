import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class CampusNetworkStatCards extends StatelessWidget {
  const CampusNetworkStatCards({
    super.key,
    required this.isDark,
    required this.totalCount,
    required this.activeCount,
    required this.isArmorActive,
  });

  final bool isDark;
  final int totalCount;
  final int activeCount;
  final bool isArmorActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            isDark: isDark,
            title: 'Total Routers',
            value: totalCount.toString(),
            icon: Icons.router_rounded,
            accentColor: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            isDark: isDark,
            title: 'Active APs',
            value: activeCount.toString(),
            icon: Icons.wifi_rounded,
            accentColor: AppColors.emeraldPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            isDark: isDark,
            title: 'Geofence Armor',
            value: isArmorActive ? 'ARMED' : 'OFF',
            icon: Icons.shield_rounded,
            accentColor: isArmorActive ? AppColors.goldPrimary : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0x331E293B) : Colors.white).withValues(
          alpha: isDark ? 0.45 : 0.94,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.10 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: accentColor),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : AppColors.textLightSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.charcoalDark,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
