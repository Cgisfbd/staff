import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:printing/printing.dart';
import 'package:staff_app/core/l10n/app_strings.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';
import 'package:staff_app/core/widgets/app_background.dart';
import 'package:staff_app/core/widgets/app_snack_bar.dart';
import 'package:staff_app/core/widgets/pdf/pdf_metadata_sheet.dart';

/// Google Drive Style Institutional PDF Viewer Engine
///
/// Features:
/// 1. Authentic Google Drive Top App Bar (Back, Title, Search, 3-Dots Overflow Menu)
/// 2. ERP Branded Mesh Gradient Canvas Background
/// 3. Continuous Vertical Page Flow with Drop Shadows
/// 4. Auto-Hiding Top Bar on Single Tap (Immersive Full-Screen Focus)
/// 5. Google Drive Style In-Document Search Bar HUD
/// 6. Floating Page Indicator Pill (e.g. 1 / 1)
/// 7. 90° Rotation via Overflow Menu
/// 8. Native System Wireless AirPrint & Print Preview
/// 9. Native Share / Send Copy via [Printing.sharePdf]
/// 10. Direct Storage Export to Device Application Documents
class GlobalPdfViewer extends StatefulWidget {
  const GlobalPdfViewer({
    super.key,
    required this.title,
    required this.fileName,
    this.subtitle = '',
    this.pdfBytesFuture,
    this.bytes,
    this.file,
    this.isLandscape = false,
    this.actions,
  }) : assert(
          pdfBytesFuture != null || bytes != null || file != null,
          'Must provide either pdfBytesFuture, bytes, or file',
        );

  final String title;
  final String subtitle;
  final String fileName;
  final Future<Uint8List> Function()? pdfBytesFuture;
  final Uint8List? bytes;
  final File? file;
  final bool isLandscape;
  final List<Widget>? actions;

  /// Global one-line static launcher
  static Future<T?> open<T>(
    BuildContext context, {
    required String title,
    required String fileName,
    String subtitle = '',
    Future<Uint8List> Function()? pdfBytesFuture,
    Uint8List? bytes,
    File? file,
    bool isLandscape = false,
    List<Widget>? actions,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (ctx) => GlobalPdfViewer(
          title: title,
          fileName: fileName,
          subtitle: subtitle,
          pdfBytesFuture: pdfBytesFuture,
          bytes: bytes,
          file: file,
          isLandscape: isLandscape,
          actions: actions,
        ),
      ),
    );
  }

  @override
  State<GlobalPdfViewer> createState() => _GlobalPdfViewerState();
}

class _GlobalPdfViewerState extends State<GlobalPdfViewer> {
  Uint8List? _cachedBytes;
  bool _isLoading = true;
  String? _errorMessage;

  // Google Drive Style Controls & pdfrx Engine
  final PdfViewerController _pdfViewerController = PdfViewerController();
  PdfTextSearcher? _textSearcher;

  bool _showTopBar = true;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  int _quarterTurns = 0; // 0, 1 (90°), 2 (180°), 3 (270°)

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(_onViewerControllerUpdated);
    _loadPdfData();
  }

  void _onViewerControllerUpdated() {
    if (mounted) setState(() {});
  }

  void _onSearchUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pdfViewerController.removeListener(_onViewerControllerUpdated);
    _textSearcher?.removeListener(_onSearchUpdated);
    _textSearcher?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.bytes != null) {
        _cachedBytes = widget.bytes;
      } else if (widget.file != null) {
        _cachedBytes = await widget.file!.readAsBytes();
      } else if (widget.pdfBytesFuture != null) {
        _cachedBytes = await widget.pdfBytesFuture!();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleTopBar() {
    if (_isSearchOpen) return;
    HapticFeedback.selectionClick();
    setState(() {
      _showTopBar = !_showTopBar;
    });
  }

  void _rotateClockwise() {
    HapticFeedback.mediumImpact();
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  Future<void> _handleSaveToDevice() async {
    if (_cachedBytes == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final sanitized = widget.fileName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final file = File('${dir.path}/$sanitized.pdf');
      await file.writeAsBytes(_cachedBytes!);

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          '${context.tr('pdf_download_success')} ($sanitized.pdf)',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to save PDF: $e');
      }
    }
  }

  Future<void> _handleShare() async {
    if (_cachedBytes == null) return;
    try {
      final sanitized = widget.fileName.replaceAll(RegExp(r'[^\w\.-]'), '_');
      await Printing.sharePdf(
        bytes: _cachedBytes!,
        filename: '$sanitized.pdf',
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Share failed: $e');
      }
    }
  }

  Future<void> _handlePrint() async {
    if (_cachedBytes == null) return;
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => _cachedBytes!,
        name: widget.fileName,
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Print error: $e');
      }
    }
  }

  void _showDetailsSheet() {
    if (_cachedBytes == null && widget.file == null) return;
    final byteSize = _cachedBytes?.lengthInBytes ?? (widget.file?.lengthSync() ?? 0);
    PdfMetadataSheet.show(
      context,
      title: widget.title,
      fileName: widget.fileName,
      byteSize: byteSize,
      isLandscape: widget.isLandscape || (_quarterTurns % 2 != 0),
      pageCount: _pdfViewerController.isReady ? _pdfViewerController.pageCount : 1,
      onShare: _handleShare,
      onPrint: _handlePrint,
      onSave: _handleSaveToDevice,
    );
  }

  void _onSearchQueryChanged(String query) {
    if (query.trim().isEmpty) {
      _textSearcher?.resetTextSearch();
      return;
    }
    _textSearcher?.startTextSearch(query);
  }

  void _nextSearchMatch() {
    HapticFeedback.selectionClick();
    _textSearcher?.goToNextMatch();
  }

  void _prevSearchMatch() {
    HapticFeedback.selectionClick();
    _textSearcher?.goToPrevMatch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1712) : const Color(0xFFF7FAF8),
      body: AppBackground(
        useSafeArea: true,
        child: Stack(
          children: [
            // 1. Continuous Vertical PDF Flow (Tappable to toggle Google Drive top bar)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleTopBar,
                behavior: HitTestBehavior.opaque,
                child: _isLoading
                    ? _buildLoadingState(isDark)
                    : _errorMessage != null
                        ? _buildErrorState(isDark)
                        : _buildPdfCanvas(isDark),
              ),
            ),

            // 2. Google Drive Style Animated Top Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              top: _showTopBar ? 0 : -90,
              left: 0,
              right: 0,
              child: _isSearchOpen
                  ? _buildGoogleDriveSearchBar(context, isDark)
                  : _buildGoogleDriveTopBar(context, isDark),
            ),

            // 3. Google Drive Style Floating Page Scrubber Pill (Right / Bottom-Center)
            if (!_isLoading && _errorMessage == null && _pdfViewerController.isReady)
              Positioned(
                bottom: 24,
                right: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showTopBar ? 1.0 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black87 : const Color(0xDD303030)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_pdfViewerController.pageNumber ?? 1} / ${_pdfViewerController.pageCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Google Drive Style Minimalist Top App Bar
  // ---------------------------------------------------------------------------
  Widget _buildGoogleDriveTopBar(BuildContext context, bool isDark) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xEE121B16) : Colors.white.withValues(alpha: 0.96)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              // Standard Google Drive Back Button
              IconButton(
                icon: Icon(
                  isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                  size: 22,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 22,
              ),

              // Document Title (Single line, bold, scales cleanly)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),

              // Custom Page Actions (e.g. Edit Student button)
              if (widget.actions != null) ...widget.actions!,

              // Search Icon (In-Document Search)
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
                tooltip: 'Search in document',
                onPressed: () {
                  setState(() {
                    _isSearchOpen = true;
                  });
                },
                splashRadius: 22,
              ),

              // 3-Dots Overflow Menu (Google Drive Style)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 22,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
                color: isDark ? const Color(0xFF1E2922) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 8,
                onSelected: (value) {
                  switch (value) {
                    case 'share':
                      _handleShare();
                      break;
                    case 'download':
                      _handleSaveToDevice();
                      break;
                    case 'print':
                      _handlePrint();
                      break;
                    case 'rotate':
                      _rotateClockwise();
                      break;
                    case 'details':
                      _showDetailsSheet();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  _buildPopupMenuItem(
                    value: 'share',
                    icon: Icons.share_outlined,
                    label: context.tr('pdf_share_file'),
                    isDark: isDark,
                  ),
                  _buildPopupMenuItem(
                    value: 'download',
                    icon: Icons.download_outlined,
                    label: context.tr('download_pdf_btn'),
                    isDark: isDark,
                  ),
                  _buildPopupMenuItem(
                    value: 'print',
                    icon: Icons.print_outlined,
                    label: context.tr('print_pdf_btn'),
                    isDark: isDark,
                  ),
                  const PopupMenuDivider(height: 1),
                  _buildPopupMenuItem(
                    value: 'rotate',
                    icon: Icons.rotate_right_rounded,
                    label: '${context.tr('pdf_rotate')} (${_quarterTurns * 90}°)',
                    isDark: isDark,
                  ),
                  _buildPopupMenuItem(
                    value: 'details',
                    icon: Icons.info_outline_rounded,
                    label: context.tr('pdf_doc_info'),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: isDark ? AppColors.goldChampagne : const Color(0xFF444746)),
          const SizedBox(width: 14),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F1F1F),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Google Drive In-Document Search Bar
  // ---------------------------------------------------------------------------
  Widget _buildGoogleDriveSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1A241E) : Colors.white),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: isDark ? Colors.white70 : const Color(0xFF444746),
                ),
                onPressed: () {
                  setState(() {
                    _isSearchOpen = false;
                    _searchController.clear();
                    _textSearcher?.resetTextSearch();
                  });
                },
                splashRadius: 20,
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchQueryChanged,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Find in document...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if ((_textSearcher?.matches.length ?? 0) > 0)
                Text(
                  '${(_textSearcher?.currentIndex != null ? _textSearcher!.currentIndex! + 1 : 0)} of ${_textSearcher!.matches.length}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.goldChampagne : AppColors.goldDark,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
                onPressed: _prevSearchMatch,
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                onPressed: _nextSearchMatch,
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Clean Canvas Flow (Google Drive Style Hardware Accelerated pdfrx)
  // ---------------------------------------------------------------------------
  Widget _buildPdfCanvas(bool isDark) {
    if (_cachedBytes == null && widget.file == null) {
      return _buildLoadingState(isDark);
    }

    final viewerParams = PdfViewerParams(
      backgroundColor: Colors.transparent,
      margin: 8,
      pagePaintCallbacks: [
        if (_textSearcher != null) _textSearcher!.pageTextMatchPaintCallback,
      ],
      onViewerReady: (document, controller) {
        if (_textSearcher == null) {
          _textSearcher = PdfTextSearcher(controller)..addListener(_onSearchUpdated);
          if (mounted) setState(() {});
        }
      },
    );

    Widget viewer;
    if (_cachedBytes != null) {
      viewer = PdfViewer.data(
        _cachedBytes!,
        sourceName: widget.fileName,
        key: ValueKey('pdf_bytes_${widget.fileName}_$_quarterTurns'),
        controller: _pdfViewerController,
        params: viewerParams,
      );
    } else {
      viewer = PdfViewer.file(
        widget.file!.path,
        key: ValueKey('pdf_file_${widget.file!.path}_$_quarterTurns'),
        controller: _pdfViewerController,
        params: viewerParams,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: RotatedBox(
        quarterTurns: _quarterTurns,
        child: viewer,
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading document...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.statusAbsent, size: 40),
            const SizedBox(height: 12),
            Text(
              'Failed to load PDF',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPdfData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Global extension for one-line opening anywhere in the app
extension GlobalPdfViewerExtension on BuildContext {
  Future<T?> openPdf<T>({
    required String title,
    required String fileName,
    String subtitle = '',
    Future<Uint8List> Function()? pdfBytesFuture,
    Uint8List? bytes,
    File? file,
    bool isLandscape = false,
  }) {
    return GlobalPdfViewer.open<T>(
      this,
      title: title,
      fileName: fileName,
      subtitle: subtitle,
      pdfBytesFuture: pdfBytesFuture,
      bytes: bytes,
      file: file,
      isLandscape: isLandscape,
    );
  }
}
