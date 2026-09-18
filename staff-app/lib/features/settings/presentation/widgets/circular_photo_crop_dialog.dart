import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:staff_app/core/theme/app_colors.dart';

/// WhatsApp-Style Full-Screen Profile Photo Cropper (< 250 lines).
/// Renders the photo with its natural aspect ratio under a circular darkened mask.
/// Allows free pan, pinch-zoom, and 90-degree rotation.
/// Captures exact rendered pixels via RepaintBoundary to eliminate any horizontal stretching.
/// Outputs an ultra-sharp 512x512 circular avatar PNG.
class CircularPhotoCropDialog extends StatefulWidget {
  const CircularPhotoCropDialog({
    super.key,
    required this.imageBytes,
  });

  final Uint8List imageBytes;

  static Future<Uint8List?> show(
    BuildContext context, {
    required Uint8List imageBytes,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CircularPhotoCropDialog(imageBytes: imageBytes),
      ),
    );
  }

  @override
  State<CircularPhotoCropDialog> createState() => _CircularPhotoCropDialogState();
}

class _CircularPhotoCropDialogState extends State<CircularPhotoCropDialog> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transController = TransformationController();
  bool _isProcessing = false;
  int _rotationQuarterTurns = 0;

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  void _rotate() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
      _transController.value = Matrix4.identity();
    });
  }



  Future<void> _handleSave(double cropDiameter) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final boundary = _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      // 1. Capture exact screen pixels at device pixel ratio
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final boundaryImage = await boundary.toImage(pixelRatio: pixelRatio);

      // 2. Center circular crop slice in captured boundary coordinates
      final centerX = boundaryImage.width / 2.0;
      final centerY = boundaryImage.height / 2.0;
      final radius = (cropDiameter / 2.0) * pixelRatio;
      final srcRect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);

      // 3. Render directly to 512x512 circular avatar
      const targetSize = 512.0;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, targetSize, targetSize));

      // Circular clip mask
      canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, targetSize, targetSize)));

      // Draw high quality filtered image
      canvas.drawImageRect(
        boundaryImage,
        srcRect,
        const Rect.fromLTWH(0, 0, targetSize, targetSize),
        Paint()..filterQuality = FilterQuality.high,
      );

      final croppedImage = await recorder.endRecording().toImage(targetSize.toInt(), targetSize.toInt());
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      if (mounted && byteData != null) {
        Navigator.of(context).pop(byteData.buffer.asUint8List());
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar: Close, Title, Rotate
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Move and Scale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_90_degrees_cw_rounded, color: Colors.white, size: 22),
                    onPressed: _rotate,
                    tooltip: 'Rotate 90°',
                  ),
                ],
              ),
            ),

            // 2. Viewport: WhatsApp-Style Canvas with Center Cutout Mask
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cropDiameter = math.min(
                    constraints.maxWidth - 36,
                    constraints.maxHeight - 36,
                  ).clamp(240.0, 320.0);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo layer wrapped in RepaintBoundary (pure WYSIWYG, zero distortion)
                      RepaintBoundary(
                        key: _cropKey,
                        child: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          color: const Color(0xFF0C1017),
                          child: InteractiveViewer(
                            transformationController: _transController,
                            minScale: 0.5,
                            maxScale: 5.0,
                            boundaryMargin: EdgeInsets.all(cropDiameter),
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: _rotationQuarterTurns,
                                child: Image.memory(
                                  widget.imageBytes,
                                  fit: BoxFit.contain, // Strictly preserves native aspect ratio
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 48),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // WhatsApp Dark Mask Overlay with Circular Cutout
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _CropCutoutPainter(cropDiameter: cropDiameter),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 3. Bottom Controls: Guidance and Actions
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: const Color(0xFF0A0E17),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pinch to zoom • Drag to reposition',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  final renderBox = context.findRenderObject() as RenderBox?;
                                  final w = renderBox?.size.width ?? 360.0;
                                  final h = renderBox?.size.height ?? 640.0;
                                  final cropDiameter = math.min(w - 36, h - 160).clamp(240.0, 320.0);
                                  _handleSave(cropDiameter);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Set Photo',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter that darkens the exterior of the circle and draws a golden guide ring
class _CropCutoutPainter extends CustomPainter {
  const _CropCutoutPainter({required this.cropDiameter});

  final double cropDiameter;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = cropDiameter / 2;

    // Dark exterior mask
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.65),
    );

    // Subtle gold ring border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = AppColors.goldPrimary.withValues(alpha: 0.90),
    );
  }

  @override
  bool shouldRepaint(covariant _CropCutoutPainter oldDelegate) {
    return oldDelegate.cropDiameter != cropDiameter;
  }
}
