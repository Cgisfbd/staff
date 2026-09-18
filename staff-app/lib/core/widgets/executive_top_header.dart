import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Institutional Executive Top Header Bar (< 100 lines).
/// Strictly mirrors the gold-frosted luxury aesthetic across Settings, Attendance, E-Books & Menu.
class ExecutiveTopHeader extends StatelessWidget {
  const ExecutiveTopHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.bottom,
    this.onIconTap,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 10),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onIconTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onIconTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldPrimary, AppColors.goldDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              if (bottom != null) ...[
                const SizedBox(height: 10),
                bottom!,
              ],
            ],
          ),
        ),
        // Thin Gold Hairline matching Settings & Menu Page
        Container(
          height: 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.goldPrimary.withValues(alpha: isDark ? 0.32 : 0.22),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
