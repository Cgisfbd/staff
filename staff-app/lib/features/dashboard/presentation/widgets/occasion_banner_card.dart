import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/features/dashboard/domain/models/occasion_banner.dart';

/// Dynamic Occasion & Event Announcement Banner with Liquid Crystal Glass Framing (< 190 lines).
class OccasionBannerCard extends StatefulWidget {
  const OccasionBannerCard({
    super.key,
    required this.banners,
    this.onDismiss,
  });

  final List<OccasionBanner> banners;
  final ValueChanged<String>? onDismiss;

  @override
  State<OccasionBannerCard> createState() => _OccasionBannerCardState();
}

class _OccasionBannerCardState extends State<OccasionBannerCard> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant OccasionBannerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerCount = widget.banners.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 165,
            child: PageView.builder(
              controller: _pageController,
              itemCount: bannerCount,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return _buildSingleBanner(context, banner, isDark);
              },
            ),
          ),
          if (bannerCount > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerCount, (i) {
                final isSelected = _currentPage == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  width: isSelected ? 18 : 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.goldPrimary
                        : (isDark ? Colors.white24 : Colors.black12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleBanner(BuildContext context, OccasionBanner banner, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x381E293B)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.goldPrimary.withValues(alpha: 0.35)
                  : AppColors.goldPrimary.withValues(alpha: 0.30),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image (Asset or Network) with Gradient Scrim
              if (banner.imagePath != null && banner.imagePath!.isNotEmpty)
                _buildBannerImage(banner.imagePath!),

              // Subtle Gradient Overlay for Text Readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),

              // Content Layer: Badge + Title + Subtitle + Action
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar: Occasion Badge + Dismiss Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: (banner.badgeColor ?? AppColors.goldPrimary).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              banner.localizedBadge(context).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        if (banner.isDismissible)
                          InkWell(
                            onTap: () => widget.onDismiss?.call(banner.id),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 0.8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Bottom Content: Title & Subtitle / Action
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner.localizedTitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                        if (banner.localizedSubtitle(context) != null && banner.localizedSubtitle(context)!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            banner.localizedSubtitle(context)!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.90),
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildBannerImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
