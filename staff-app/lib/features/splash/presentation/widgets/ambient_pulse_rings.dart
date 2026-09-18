import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Multi-layered breathing concentric golden rings with rotation and pulse.
/// Strictly compliant with TaleemOne ERP Splash Screen standard.
class AmbientPulseRings extends StatefulWidget {
  final double size;
  const AmbientPulseRings({super.key, this.size = 160});

  @override
  State<AmbientPulseRings> createState() => _AmbientPulseRingsState();
}

class _AmbientPulseRingsState extends State<AmbientPulseRings> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.goldLight : AppColors.goldPrimary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Wave 1
              Transform.scale(
                scale: 1.0 + (progress * 0.45),
                child: Opacity(
                  opacity: (1.0 - progress).clamp(0.0, 0.7),
                  child: Container(
                    width: widget.size * 1.35,
                    height: widget.size * 1.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: baseColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Middle Wave 2 (delayed phase)
              Transform.scale(
                scale: 1.0 + (((progress + 0.5) % 1.0) * 0.35),
                child: Opacity(
                  opacity: (1.0 - ((progress + 0.5) % 1.0)).clamp(0.0, 0.6),
                  child: Container(
                    width: widget.size * 1.15,
                    height: widget.size * 1.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: baseColor.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              // Ambient Rotating Golden Dash Ring
              Transform.rotate(
                angle: progress * 2 * math.pi,
                child: Container(
                  width: widget.size * 0.96,
                  height: widget.size * 0.96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.0),
                        baseColor.withValues(alpha: 0.4),
                        baseColor.withValues(alpha: 0.8),
                        baseColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        );
      },
    );
  }
}
