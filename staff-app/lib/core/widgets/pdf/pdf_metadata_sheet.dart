import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// Institutional Glassmorphic Document Metadata Sheet
class PdfMetadataSheet extends StatelessWidget {
  const PdfMetadataSheet({
    super.key,
    required this.title,
    required this.fileName,
    required this.byteSize,
    required this.isLandscape,
    this.pageCount = 1,
    required this.onShare,
    required this.onPrint,
    required this.onSave,
  });

  final String title;
  final String fileName;
  final int byteSize;
  final bool isLandscape;
  final int pageCount;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onSave;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String fileName,
    required int byteSize,
    required bool isLandscape,
    int pageCount = 1,
    required VoidCallback onShare,
    required VoidCallback onPrint,
    required VoidCallback onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => PdfMetadataSheet(
        title: title,
        fileName: fileName,
        byteSize: byteSize,
        isLandscape: isLandscape,
        pageCount: pageCount,
        onShare: onShare,
        onPrint: onPrint,
        onSave: onSave,
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xDD121C16) : Colors.white.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white38 : Colors.black26),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Verified Icon
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      size: 20,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$fileName.pdf',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 12, color: AppColors.goldPrimary),
                        SizedBox(width: 4),
                        Text(
                          'OFFICIAL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: AppColors.goldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metadata Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.25 : 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      isDark: isDark,
                      icon: Icons.data_usage_rounded,
                      label: context.tr('pdf_file_size'),
                      value: _formatBytes(byteSize),
                    ),
                    const Divider(height: 14, thickness: 0.7),
                    _buildInfoRow(
                      context: context,
                      isDark: isDark,
                      icon: Icons.layers_rounded,
                      label: context.tr('pdf_pages_count'),
                      value: '$pageCount',
                    ),
                    const Divider(height: 14, thickness: 0.7),
                    _buildInfoRow(
                      context: context,
                      isDark: isDark,
                      icon: isLandscape ? Icons.crop_landscape_rounded : Icons.crop_portrait_rounded,
                      label: context.tr('pdf_orientation'),
                      value: isLandscape
                          ? context.tr('pdf_landscape')
                          : context.tr('pdf_portrait'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Security Seal
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: AppColors.goldPrimary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.tr('pdf_verified_seal'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Action Buttons Row
              Row(
                children: [
                  // Share Button
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      isDark: isDark,
                      icon: Icons.share_rounded,
                      label: context.tr('pdf_share_file'),
                      onTap: () {
                        Navigator.of(context).pop();
                        onShare();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Print Button
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      isDark: isDark,
                      icon: Icons.print_rounded,
                      label: context.tr('print_pdf_btn'),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPrint();
                      },
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

  Widget _buildInfoRow({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.goldChampagne : AppColors.goldDark),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.45),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isDark ? AppColors.goldChampagne : AppColors.goldDark),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
