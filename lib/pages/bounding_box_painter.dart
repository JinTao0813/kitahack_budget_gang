import 'package:flutter/material.dart';
import 'package:kitahack_budget_gang/pages/camera_screen.dart'; // Import the Detection class

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final double previewWidth;
  final double previewHeight;

  BoundingBoxPainter(this.detections, this.previewWidth, this.previewHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(color: Colors.white, fontSize: 14);

    for (var detection in detections) {
      final scaled = Rect.fromLTWH(
        detection.rect.left * size.width / previewWidth,
        detection.rect.top * size.height / previewHeight,
        detection.rect.width * size.width / previewWidth,
        detection.rect.height * size.height / previewHeight,
      );

      canvas.drawRect(scaled, paint);

      final textSpan = TextSpan(
        text:
            'Class: ${detection.classId}, ${(detection.confidence * 100).toStringAsFixed(1)}%',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      textPainter.paint(canvas, Offset(scaled.left, scaled.top - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
