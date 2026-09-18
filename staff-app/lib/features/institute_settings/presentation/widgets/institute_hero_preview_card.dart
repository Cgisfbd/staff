import 'dart:io';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';

class InstituteHeroPreviewCard extends StatelessWidget {
  const InstituteHeroPreviewCard({
    super.key,
    required this.model,
    this.localLogoPath,
    this.localBannerPath,
  });

  final InstituteSettingsUiModel model;
  final String? localLogoPath;
  final String? localBannerPath;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.goldPrimary.withValues(alpha: 0.3) : AppColors.goldPrimary.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(child: _buildBannerBackground(isDark)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: AppColors.goldChampagne),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  model.instituteType.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.goldChampagne,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (model.affiliationNumber.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              model.affiliationNumber,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E212A) : Colors.white,
                      border: Border.all(color: AppColors.goldPrimary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(child: _buildLogoImage()),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    model.nameEn.isNotEmpty ? model.nameEn : 'TaleemOne ERP',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  if (model.nameUr.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      model.nameUr,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.goldChampagne),
                    ),
                  ],
                  if (model.taglineEn.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      model.taglineEn,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                  if (model.quotesMain.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        model.quotesMain,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.goldPrimary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerBackground(bool isDark) {
    if (localBannerPath != null && localBannerPath!.isNotEmpty) {
      final file = File(localBannerPath!);
      if (file.existsSync()) return Image.file(file, fit: BoxFit.cover);
    }
    if (model.bannerUrl.isNotEmpty && !model.bannerUrl.contains('default')) {
      return Image.network(
        model.bannerUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAtmosphere(),
      );
    }
    return _fallbackAtmosphere();
  }

  Widget _fallbackAtmosphere() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1812), Color(0xFF2D2314), Color(0xFF0F0E0C)],
        ),
      ),
    );
  }

  Widget _buildLogoImage() {
    if (localLogoPath != null && localLogoPath!.isNotEmpty) {
      final file = File(localLogoPath!);
      if (file.existsSync()) return Image.file(file, fit: BoxFit.contain);
    }
    if (model.logoUrl.isNotEmpty && !model.logoUrl.contains('default')) {
      return Image.network(
        model.logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_rounded, size: 36, color: AppColors.goldPrimary),
      );
    }
    return const Icon(Icons.account_balance_rounded, size: 36, color: AppColors.goldPrimary);
  }
}
