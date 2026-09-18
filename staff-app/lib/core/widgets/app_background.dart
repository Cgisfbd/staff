import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Clean, Pixel-Perfect Canvas strictly matching the TaleemOne ERP Staff Application.
/// Ambient warm golden glow in light mode, deep obsidian slate with luminous gold orbs in dark mode with 60fps rendering.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Container(
      color: baseColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _PixelPerfectErpCanvas(isDark: isDark),
              size: Size.infinite,
            ),
          ),
          if (useSafeArea)
            SafeArea(
              child: child,
            )
          else
            child,
        ],
      ),
    );
  }
}

class _PixelPerfectErpCanvas extends CustomPainter {
  const _PixelPerfectErpCanvas({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (isDark) {
      // Dark Mode: Deep obsidian with exact TaleemOne ambient warm golden glowing spheres
      final topGlowColor = AppColors.goldDark.withValues(alpha: 0.16);
      final bottomGlowColor = AppColors.goldPrimary.withValues(alpha: 0.12);

      // Top-Right Golden Sphere
      final paintTopGlow = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.9, -0.85),
          radius: 0.85,
          colors: [
            topGlowColor,
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paintTopGlow);

      // Bottom-Left Golden Sphere
      final paintBottomGlow = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.85, 0.85),
          radius: 0.80,
          colors: [
            bottomGlowColor,
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paintBottomGlow);
    } else {
      // Light Mode: Clean soft ivory with exact TaleemOne amber gold radiant lighting
      final topGlowColor = AppColors.goldLight.withValues(alpha: 0.16);
      final bottomGlowColor = AppColors.goldBright.withValues(alpha: 0.12);

      // Top-Right Amber Sphere
      final paintTopLightGlow = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.9, -0.85),
          radius: 0.85,
          colors: [
            topGlowColor,
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paintTopLightGlow);

      // Bottom-Left Bright Amber Sphere
      final paintBottomLightGlow = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.85, 0.85),
          radius: 0.80,
          colors: [
            bottomGlowColor,
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paintBottomLightGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPerfectErpCanvas oldDelegate) =>
      oldDelegate.isDark != isDark;
}
