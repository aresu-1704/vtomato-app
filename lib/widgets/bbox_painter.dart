import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/detection_model.dart';

/// Custom painter for drawing bounding boxes on images
class BBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final Size imageSize;

  BBoxPainter({required this.detections, required this.imageSize});

  /// Generate unique color for each class
  Color _getClassColor(int classId) {
    // Use HSV color space for distinct colors
    final hue = (classId * 40) % 360;
    return HSVColor.fromAHSV(1.0, hue.toDouble(), 0.8, 0.9).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    // Calculate scale factors
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // DEBUG: Print once
    if (detections.isNotEmpty) {
      print('[DEBUG BBoxPainter] Canvas size: ${size.width}x${size.height}');
      print(
        '[DEBUG BBoxPainter] Image size: ${imageSize.width}x${imageSize.height}',
      );
      print(
        '[DEBUG BBoxPainter] Scale factors: scaleX=$scaleX, scaleY=$scaleY',
      );
    }

    for (var i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final bbox = detection.bbox;

      // Scale bbox coordinates
      final rect = Rect.fromLTRB(
        bbox[0] * scaleX,
        bbox[1] * scaleY,
        bbox[2] * scaleX,
        bbox[3] * scaleY,
      );

      // DEBUG: Print first detection
      if (i == 0) {
        print(
          '[DEBUG BBoxPainter] Original bbox: [${bbox[0]}, ${bbox[1]}, ${bbox[2]}, ${bbox[3]}]',
        );
        print(
          '[DEBUG BBoxPainter] Scaled rect: ${rect.left}, ${rect.top}, ${rect.right}, ${rect.bottom}',
        );
      }

      // Get class color
      final color = _getClassColor(detection.classId);

      // Draw bounding box
      final boxPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

      canvas.drawRect(rect, boxPaint);

      // Draw label background and text
      _drawLabel(canvas, rect, detection, color);
    }
  }

  void _drawLabel(Canvas canvas, Rect rect, Detection detection, Color color) {
    final label = detection.className;

    // Text style
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(text: label, style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Calculate label position (above the box)
    final labelX = rect.left;
    final labelY = rect.top - textPainter.height - 8;

    // Draw label background
    final labelBgRect = Rect.fromLTWH(
      labelX,
      labelY,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    final labelBgPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawRect(labelBgRect, labelBgPaint);

    // Draw text
    textPainter.paint(canvas, Offset(labelX + 4, labelY + 2));
  }

  @override
  bool shouldRepaint(BBoxPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.imageSize != imageSize;
  }
}

/// Widget that displays an image with bounding boxes overlay
/// Uses ui.Image directly to avoid automatic EXIF rotation
class DetectionOverlay extends StatefulWidget {
  final ImageProvider imageProvider;
  final List<Detection> detections;
  final Size imageSize;
  final BoxFit fit;

  const DetectionOverlay({
    Key? key,
    required this.imageProvider,
    required this.detections,
    required this.imageSize,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<DetectionOverlay> createState() => _DetectionOverlayState();
}

class _DetectionOverlayState extends State<DetectionOverlay> {
  ui.Image? _uiImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(DetectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final ImageStream stream = widget.imageProvider.resolve(
      ImageConfiguration.empty,
    );
    final completer = Completer<ui.Image>();

    void listener(ImageInfo info, bool _) {
      completer.complete(info.image);
    }

    stream.addListener(ImageStreamListener(listener));

    final image = await completer.future;

    if (mounted) {
      setState(() {
        _uiImage = image;
        _loading = false;
      });

      // DEBUG: Print actual image dimensions from decoded ui.Image
      print(
        '[DEBUG DetectionOverlay] Decoded ui.Image: ${image.width}x${image.height}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Print aspect ratio
    final aspectRatio = widget.imageSize.width / widget.imageSize.height;
    print(
      '[DEBUG DetectionOverlay] AspectRatio set to: $aspectRatio (${widget.imageSize.width}/${widget.imageSize.height})',
    );

    if (_loading || _uiImage == null) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CustomPaint(
        painter: _CombinedPainter(
          image: _uiImage!,
          detections: widget.detections,
          imageSize: widget.imageSize,
          fit: widget.fit,
        ),
      ),
    );
  }
}

/// Custom painter that draws both image and bboxes
/// This completely bypasses Flutter's Image widget auto-rotation
class _CombinedPainter extends CustomPainter {
  final ui.Image image;
  final List<Detection> detections;
  final Size imageSize;
  final BoxFit fit;

  _CombinedPainter({
    required this.image,
    required this.detections,
    required this.imageSize,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw image
    final srcSize = Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(fit, srcSize, size);
    final Rect src = Alignment.center.inscribe(
      sizes.source,
      Offset.zero & srcSize,
    );
    final Rect dst = Alignment.center.inscribe(
      sizes.destination,
      Offset.zero & size,
    );

    canvas.drawImageRect(image, src, dst, Paint());

    // Draw bboxes
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (var i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final bbox = detection.bbox;

      final rect = Rect.fromLTRB(
        bbox[0] * scaleX,
        bbox[1] * scaleY,
        bbox[2] * scaleX,
        bbox[3] * scaleY,
      );

      final color = _getClassColor(detection.classId);

      // Draw box
      final boxPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

      canvas.drawRect(rect, boxPaint);

      // Draw label
      _drawLabel(canvas, rect, detection.className, color);
    }
  }

  Color _getClassColor(int classId) {
    final hue = (classId * 40) % 360;
    return HSVColor.fromAHSV(1.0, hue.toDouble(), 0.8, 0.9).toColor();
  }

  void _drawLabel(Canvas canvas, Rect rect, String label, Color color) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = rect.left;
    final labelY = rect.top - textPainter.height - 8;

    final labelBgRect = Rect.fromLTWH(
      labelX,
      labelY,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    canvas.drawRect(labelBgRect, Paint()..color = color);
    textPainter.paint(canvas, Offset(labelX + 4, labelY + 2));
  }

  @override
  bool shouldRepaint(_CombinedPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.detections != detections ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.fit != fit;
  }
}
