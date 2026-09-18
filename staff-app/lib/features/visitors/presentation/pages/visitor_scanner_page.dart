import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/utils/formatters.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/features/visitors/data/datasources/visitor_datasource.dart';
import 'package:staff_app/features/visitors/domain/models/visitor_pass_model.dart';

/// Production-Grade Universal Visitor Pass Scanner & Quota Deduction Screen
/// - Live Hardware Camera Feed (MobileScanner)
/// - Dedicated Ultra-Premium Manual Card Input
/// - Real-Time Visitor & Student Verification Card
/// - One-Tap Visit Quota Deduction with Zero-Quota Exhaustion Armor
/// - Guaranteed Zero-Overflow across 320dp to Tablets (Rule 12).
class VisitorScannerPage extends StatefulWidget {
  const VisitorScannerPage({super.key});

  @override
  State<VisitorScannerPage> createState() => _VisitorScannerPageState();
}

class _VisitorScannerPageState extends State<VisitorScannerPage>
    with SingleTickerProviderStateMixin {
  final VisitorDatasource _datasource = VisitorDatasource();
  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocusNode = FocusNode();

  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  bool _isFlashOn = false;
  bool _isDeducting = false;

  DateTime? _lastScanTime;
  String? _lastScannedPayload;

  VisitorPassEntity? _activeVisitor;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOut,
    );

    // Seed initial active visitor for instant review
    _activeVisitor = _datasource.lookup('VIS-2026-881');
  }

  @override
  void dispose() {
    _manualController.dispose();
    _manualFocusNode.dispose();
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(milliseconds: 1500)) {
      return;
    }

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    if (raw == _lastScannedPayload &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(seconds: 4)) {
      return;
    }

    _lastScanTime = now;
    _lastScannedPayload = raw;
    unawaited(HapticFeedback.mediumImpact());

    _processCardLookup(raw);
  }

  void _processCardLookup(String query) {
    final visitor = _datasource.lookup(query);
    if (visitor == null) {
      unawaited(HapticFeedback.vibrate());
      AppSnackBar.showError(
        context,
        context.tr('visitor_not_found', params: {'query': query}),
      );
      return;
    }

    setState(() {
      _activeVisitor = visitor;
    });

    unawaited(HapticFeedback.lightImpact());
  }

  Future<void> _handleDeductVisit() async {
    if (_activeVisitor == null || !_activeVisitor!.canDeductVisit || _isDeducting) {
      return;
    }

    setState(() => _isDeducting = true);
    unawaited(HapticFeedback.heavyImpact());

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final updated = _datasource.deductVisit(_activeVisitor!.cardId);

    if (!mounted) return;

    setState(() {
      _isDeducting = false;
      if (updated != null) {
        _activeVisitor = updated;
      }
    });

    if (updated != null) {
      AppSnackBar.showSuccess(
        context,
        context.tr(
          'visitor_deduct_success',
          params: {'remaining': updated.remainingVisits.toString()},
        ),
      );
    }
  }

  String _localizedRelation(String relation, BuildContext context) {
    switch (relation.toLowerCase()) {
      case 'father':
        return context.tr('visitor_relation_father');
      case 'mother':
        return context.tr('visitor_relation_mother');
      case 'brother':
        return context.tr('visitor_relation_brother');
      case 'guardian':
        return context.tr('visitor_relation_guardian');
      case 'uncle':
        return context.tr('visitor_relation_uncle');
      default:
        return relation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, isDark, isRtl),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      // 1. Live Camera Viewfinder (Identical twin to QR attendance)
                      _buildViewfinderDeck(isDark),
                      const SizedBox(height: 14),

                      // 2. Manual Card Number Search Card (Identical twin)
                      _buildManualInputCard(isDark, isRtl),
                      const SizedBox(height: 14),

                      // 3. Active Visitor Verification & Quota Card
                      if (_activeVisitor != null) ...[
                        _buildVisitorDetailsCard(_activeVisitor!, isDark, isRtl),
                        const SizedBox(height: 14),
                      ],

                      // 4. Today's Scanned Visitors Roster
                      _buildTodayScannedRoster(isDark, isRtl),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Navigation Bar (Identical twin to QrAttendancePage & StaffSalaryPage)
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(BuildContext context, bool isDark, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.9,
                ),
              ),
              child: Icon(
                isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('visitor_scanner_title'),
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.tr('visitor_scanner_subtitle'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Flash Toggle Button (38x38 luxury container)
          InkWell(
            onTap: () async {
              await _scannerController.toggleTorch();
              setState(() => _isFlashOn = !_isFlashOn);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _isFlashOn
                    ? AppColors.goldPrimary.withValues(alpha: 0.25)
                    : (isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.9)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFlashOn
                      ? AppColors.goldPrimary
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 0.9,
                ),
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                size: 17,
                color: _isFlashOn
                    ? AppColors.goldPrimary
                    : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Flip Camera Button (38x38 luxury container)
          InkWell(
            onTap: () => _scannerController.switchCamera(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.9,
                ),
              ),
              child: Icon(
                Icons.flip_camera_ios_rounded,
                size: 17,
                color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Live Camera Viewfinder with Glowing Laser & Reticles (Identical Twin)
  // ---------------------------------------------------------------------------
  Widget _buildViewfinderDeck(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x661E293B),
                      const Color(0x520F172A),
                      const Color(0x5C1E293B),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.96),
                      const Color(0xF7F8FAFC),
                      Colors.white.withValues(alpha: 0.94),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.45 : 0.10),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 205,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Live Hardware Camera Stream
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 40,
                              color: AppColors.goldPrimary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Camera feed ready',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Subtle Dimmed Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.85,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),

                  // Center Gold Target Reticle Box (180x140)
                  Container(
                    width: 180,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                  ),

                  // 4 Corner Reticles
                  Positioned(
                    top: 32,
                    left: 24,
                    child: _buildCornerReticle(topLeft: true),
                  ),
                  Positioned(
                    top: 32,
                    right: 24,
                    child: _buildCornerReticle(topRight: true),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 24,
                    child: _buildCornerReticle(bottomLeft: true),
                  ),
                  Positioned(
                    bottom: 32,
                    right: 24,
                    child: _buildCornerReticle(bottomRight: true),
                  ),

                  // Central Laser Sweep Line
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 38 + (_laserAnimation.value * 128),
                        left: 28,
                        right: 28,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.goldPrimary,
                                Colors.white,
                                AppColors.goldPrimary,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldPrimary.withValues(alpha: 0.85),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Bottom Scanner Status Pill
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.goldPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Flexible(
                              child: Text(
                                'Point at Visitor Pass QR Code',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerReticle({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? const BorderSide(color: AppColors.goldPrimary, width: 2.5)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? const BorderSide(color: AppColors.goldPrimary, width: 2.5)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? const BorderSide(color: AppColors.goldPrimary, width: 2.5)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? const BorderSide(color: AppColors.goldPrimary, width: 2.5)
              : BorderSide.none,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Dedicated Ultra-Premium Manual Card Input (Identical Twin Structure)
  // ---------------------------------------------------------------------------
  Widget _buildManualInputCard(bool isDark, bool isRtl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0x661E293B),
                      const Color(0x520F172A),
                      const Color(0x5C1E293B),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.96),
                      const Color(0xF7F8FAFC),
                      Colors.white.withValues(alpha: 0.94),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.40 : 0.30),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF9E7B3B))
                    .withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sleek Micro-Header Row
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.dialpad_rounded,
                        size: 15,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('visitor_manual_card_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'Instant Search',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Unified Action Row: Input Box + Verify Button
              Row(
                children: [
                  // Substantial, Styled Numeric/Code Input Box
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.40),
                          width: 1.1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pin_rounded,
                            size: 17,
                            color: AppColors.goldPrimary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _manualController,
                              focusNode: _manualFocusNode,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: context.tr('visitor_manual_hint'),
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                                isDense: true,
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: isDark ? Colors.white : AppColors.charcoalDark,
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  _processCardLookup(val.trim());
                                }
                              },
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _manualController,
                            builder: (context, value, _) {
                              if (value.text.isEmpty) return const SizedBox.shrink();
                              return GestureDetector(
                                onTap: () => _manualController.clear(),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    size: 16,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tactile "Search" Button (Flex-bounded with Gold Primary Luxury Theme)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final text = _manualController.text.trim();
                          if (text.isNotEmpty) {
                            _processCardLookup(text);
                          } else {
                            AppSnackBar.showError(
                              context,
                              context.tr('visitor_manual_hint'),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          foregroundColor: Colors.black,
                          elevation: 1.5,
                          shadowColor: AppColors.goldPrimary.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_rounded, size: 16, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                context.tr('visitor_search_btn'),
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  // ---------------------------------------------------------------------------
  // 3. Active Visitor Verification & Quota Card
  // ---------------------------------------------------------------------------
  Widget _buildVisitorDetailsCard(VisitorPassEntity v, bool isDark, bool isRtl) {
    final isExhausted = v.remainingVisits == 0;
    final relationLabel = _localizedRelation(v.relation, context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExhausted
                  ? AppColors.statusAbsent.withValues(alpha: 0.60)
                  : AppColors.goldPrimary.withValues(alpha: 0.45),
              width: 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Header: Number + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        v.cardNumber,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isExhausted ? AppColors.statusAbsent : AppColors.goldPrimary)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isExhausted ? AppColors.statusAbsent : AppColors.goldPrimary)
                                .withValues(alpha: 0.40),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExhausted ? Icons.block_rounded : Icons.check_circle_rounded,
                              size: 13,
                              color: isExhausted ? AppColors.statusAbsent : AppColors.goldPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExhausted
                                  ? context.tr('visitor_status_exhausted')
                                  : context.tr('visitor_status_active'),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: isExhausted
                                    ? AppColors.statusAbsent
                                    : (isDark ? AppColors.goldChampagne : AppColors.goldDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Visitor Profile Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldDark],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      v.visitorName.isNotEmpty ? v.visitorName[0] : 'V',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.visitorName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                relationLabel,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                v.visitorPhone,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Linked Student Section (Glass Box)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, size: 16, color: AppColors.goldPrimary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${v.studentName} (Roll #${v.studentRollNo})',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${v.studentClass} • ${v.hostelRoom}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Visit Quota HUD Ring / Counters
              Row(
                children: [
                  _buildQuotaTile(
                    label: context.tr('visitor_stat_total_allowed'),
                    value: v.totalAllowedVisits.toString(),
                    isDark: isDark,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                  const SizedBox(width: 8),
                  _buildQuotaTile(
                    label: context.tr('visitor_stat_used_visits'),
                    value: v.usedVisits.toString(),
                    isDark: isDark,
                    color: AppColors.textDarkMuted,
                  ),
                  const SizedBox(width: 8),
                  _buildQuotaTile(
                    label: context.tr('visitor_stat_remaining'),
                    value: v.remainingVisits.toString(),
                    isDark: isDark,
                    color: isExhausted ? AppColors.statusAbsent : AppColors.emeraldPrimary,
                    isHighlighted: true,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Scanned Visitor's Previous Visits History Section
              _buildVisitorHistorySection(v, isDark, isRtl),
              const SizedBox(height: 14),

              // Quota Exhausted Warning or Action Button
              if (isExhausted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.statusAbsent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.statusAbsent.withValues(alpha: 0.40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 20, color: AppColors.statusAbsent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('visitor_exhausted_warning'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.statusAbsent,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isDeducting ? null : _handleDeductVisit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldPrimary, AppColors.goldDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: _isDeducting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.remove_circle_outline_rounded,
                                          size: 18, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.tr('visitor_deduct_action'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Scanned Visitor's Previous Visits History Section
  // ---------------------------------------------------------------------------
  Widget _buildVisitorHistorySection(VisitorPassEntity v, bool isDark, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // History Section Header
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr('visitor_history_title'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${v.visitLogs.length} Recorded',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (v.visitLogs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.tr('visitor_no_history'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: v.visitLogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final log = v.visitLogs[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.35),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          'Visit #${log.visitNumber}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppFormatters.formatDate(log.timestamp)} • ${AppFormatters.formatTime(log.timestamp)}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${log.gateLocation} • ${log.deductedBy}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (log.remarks != null && log.remarks!.isNotEmpty)
                              Text(
                                log.remarks!,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.goldPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuotaTile({
    required String label,
    required String value,
    required bool isDark,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isHighlighted
              ? color.withValues(alpha: 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted
                ? color.withValues(alpha: 0.40)
                : (isDark ? Colors.white10 : Colors.black12),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Today's Scanned Visitors Roster
  // ---------------------------------------------------------------------------
  Widget _buildTodayScannedRoster(bool isDark, bool isRtl) {
    final scanned = _datasource.getTodayScanned();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded,
                          size: 16, color: AppColors.goldPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('visitor_recent_title'),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${scanned.length} Scanned',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),

              if (scanned.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.badge_outlined,
                            size: 34, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('visitor_recent_empty'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scanned.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  itemBuilder: (context, index) {
                    final item = scanned[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldPrimary.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                size: 14, color: AppColors.emeraldPrimary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.visitorName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textDarkPrimary
                                        : AppColors.textLightPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Met: ${item.studentName} (${item.studentClass})',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.textDarkMuted
                                        : AppColors.textLightMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (item.remainingVisits == 0
                                          ? AppColors.statusAbsent
                                          : AppColors.emeraldPrimary)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.remainingVisits} Left',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: item.remainingVisits == 0
                                        ? AppColors.statusAbsent
                                        : AppColors.emeraldPrimary,
                                  ),
                                ),
                              ),
                              if (item.lastVisitedAt != null)
                                Text(
                                  AppFormatters.formatTime(item.lastVisitedAt!),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: isDark
                                        ? AppColors.textDarkMuted
                                        : AppColors.textLightMuted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
