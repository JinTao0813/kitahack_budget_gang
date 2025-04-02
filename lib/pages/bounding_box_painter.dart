import 'package:flutter/material.dart';
import 'package:kitahack_budget_gang/pages/camera_screen.dart'; // Import the Detection class

final List<Color> classColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.cyanAccent,
  Colors.limeAccent,
  Colors.teal,
  Colors.indigo,
  Colors.pinkAccent,
];

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final double previewWidth;
  final double previewHeight;
  final List<String> labels;

  BoundingBoxPainter(
    this.detections,
    this.previewWidth,
    this.previewHeight,
    this.labels,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (previewWidth == 0 || previewHeight == 0) return;

    final scaleX = size.width/320;
    final scaleY = size.height/320;


    print("Canvas Size: ${size.width} x ${size.height}");
    print("Preview WxH: $previewWidth x $previewHeight");

    for (var detection in detections) {
      final Paint paint = Paint()
        ..color = classColors[detection.classId % classColors.length]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor:
            classColors[detection.classId % classColors.length].withOpacity(0.7),
      );

      final scaled = Rect.fromLTWH(
        detection.rect.left * scaleX,
        detection.rect.top * scaleY,
        detection.rect.width * scaleX,
        detection.rect.height * scaleY,
      );

      print("🟥 Box: $scaled");

      canvas.drawRect(scaled, paint);

      final textSpan = TextSpan(
        text:
            '${labels[detection.classId]}, ${(detection.confidence * 100).toStringAsFixed(1)}%',
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      textPainter.paint(
        canvas, 
        Offset(
          scaled.left.clamp(0.0, size.width - textPainter.width),
          (scaled.top - 20).clamp(0.0, size.height - textPainter.height),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}