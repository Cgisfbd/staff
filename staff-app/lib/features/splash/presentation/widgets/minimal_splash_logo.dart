import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/widgets/glass_card.dart';
import 'ambient_pulse_rings.dart';

/// Minimal FAANG-Grade Centered Logo with Animated Concentric Golden Pulse Rings.
/// Strictly aligned with TaleemOne ERP Staff Mobile App standard.
class MinimalSplashLogo extends StatelessWidget {
  const MinimalSplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: ((value - 0.5) / 0.5).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Concentric Golden Pulse Rings around official Logo
          Stack(
            alignment: Alignment.center,
            children: [
              const AmbientPulseRings(size: 160),
              GlassCard(
                padding: const EdgeInsets.all(22.0),
                borderRadius: BorderRadius.circular(22.0),
                blurSigma: 28.0,
                borderWidth: 1.2,
                customBorderColor: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                customFillColor: isDark ? AppColors.darkGlassEmblem : AppColors.lightGlassEmblem,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 86,
                  height: 86,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.school_rounded,
                    size: 54,
                    color: isDark ? AppColors.goldLight : AppColors.goldPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Main Heading: App Name
          Text(
            'TaleemOne Staff',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle Badge: Staff & Faculty Portal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            child: const Text(
              'Staff & Faculty Portal',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.goldLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
