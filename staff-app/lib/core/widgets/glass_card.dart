import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Liquid Crystal Glassmorphic Card strictly complying with:
/// FRONTEND_RULES.md Rule 3 & staffRULES.md Rule 8.2 (Zero Solid Cards Mandate).
/// Features hardware-accelerated BackdropFilter blur, luminous frosted border, and luxury depth.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius = AppSpacing.roundedMd,
    this.blurSigma = 16.0,
    this.borderWidth = 1.0,
    this.onTap,
    this.customBorderColor,
    this.customFillColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double borderWidth;
  final VoidCallback? onTap;
  final Color? customBorderColor;
  final Color? customFillColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = customFillColor ??
        (isDark ? AppColors.darkGlassSurface : AppColors.lightGlassSurface);
    final borderColor = customBorderColor ??
        (isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x40000000) : AppColors.webGlassShadow,
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      ),
    );
  }
}
