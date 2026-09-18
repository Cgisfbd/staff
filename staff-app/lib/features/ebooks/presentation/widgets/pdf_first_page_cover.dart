import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Renders the exact first page of a PDF document as an authentic visual cover.
/// Caches the rasterized PNG bytes in memory so generation only happens once.
class PdfFirstPageCover extends StatefulWidget {
  const PdfFirstPageCover({
    super.key,
    required this.cacheKey,
    required this.pdfBytesFuture,
    required this.accentColor,
    this.width = 124,
    this.height = 174,
  });

  final String cacheKey;
  final Future<Uint8List> Function() pdfBytesFuture;
  final Color accentColor;
  final double width;
  final double height;

  // In-memory static cache for rasterized first pages
  static final Map<String, Uint8List> _thumbnailCache = {};

  @override
  State<PdfFirstPageCover> createState() => _PdfFirstPageCoverState();
}

class _PdfFirstPageCoverState extends State<PdfFirstPageCover> {
  Uint8List? _pngBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant PdfFirstPageCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cacheKey != widget.cacheKey) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    // 1. Check in-memory cache first for instant 0ms retrieval
    if (PdfFirstPageCover._thumbnailCache.containsKey(widget.cacheKey)) {
      if (mounted) {
        setState(() {
          _pngBytes = PdfFirstPageCover._thumbnailCache[widget.cacheKey];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docBytes = await widget.pdfBytesFuture();
      // Rasterize page 0 at 100 DPI
      final rasterStream = Printing.raster(docBytes, pages: const [0], dpi: 100);
      await for (final page in rasterStream) {
        final png = await page.toPng();
        PdfFirstPageCover._thumbnailCache[widget.cacheKey] = png;
        if (mounted) {
          setState(() {
            _pngBytes = png;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            if (_pngBytes != null)
              Positioned.fill(
                child: Image.memory(
                  _pngBytes!,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              )
            else if (_isLoading)
              Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
                  ),
                ),
              )
            else
              Center(
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 32,
                  color: widget.accentColor.withValues(alpha: 0.5),
                ),
              ),

            // Subtle book spine shadow on the left for physical depth
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
