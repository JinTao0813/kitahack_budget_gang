// ==== camera_screen.dart (callback version) ====
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'bounding_box_painter.dart';

class CameraScreen extends StatefulWidget {
  final void Function(List<int>) onDetected;

  const CameraScreen({super.key, required this.onDetected});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Interpreter _interpreter;
  late List<String> _labels;
  List<Detection> _detections = [];
  bool _isDetecting = true;
  int _frameCount = 0;
  bool _isPaused = false;
  Set<int> _collectedClassIds = {}; // Collect unique detected numbers

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    await _loadModel();
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      _controller.startImageStream((CameraImage image) {
        _frameCount++;

        if (_isDetecting && _frameCount % 30 == 0) {
          _runInference(image);
        }
      });

      setState(() {});
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  Future<void> _loadModel() async {
    try {

      _interpreter = await Interpreter.fromAsset('assets/best_float32.tflite');

      final raw = await rootBundle.loadString('assets/labels.txt');
      _labels = raw.split('\n').map((e) => e.trim()).toList();
    } catch (e) {
      print("Model load error: $e");
    }
  }

  Future<void> _runInference(CameraImage image) async {
    try {
      final input = await _preprocessImage(image);
      List<List<List<double>>> output = List.generate(
        1,
        (_) => List.generate(300, (_) => List.filled(6, 0.0)),
      );

      _interpreter.run(input, output);
      final detections = _parseDetections(output[0]);

      setState(() {
        _detections = detections;
      });

      for (var d in _detections) {
        if (d.confidence >= 0.3) {
          if (_collectedClassIds.add(d.classId)) {
            widget.onDetected(_collectedClassIds.toList());
          }
        }
      }
    } catch (e) {
      print("Inference error: $e");
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
    CameraImage image,
  ) async {
    final rgbImage = _convertYUV420ToImage(image);
    final resized = img.copyResize(rgbImage, width: 320, height: 320);
    return [
      List.generate(
        320,
        (y) => List.generate(320, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    ];
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final buffer = img.Image(width: width, height: height);
    final plane0 = image.planes[0].bytes;
    final plane1 = image.planes[1].bytes;
    final plane2 = image.planes[2].bytes;
    int uvRowStride = image.planes[1].bytesPerRow;
    int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        int index = y * width + x;
        final yp = plane0[index];
        final up = plane1[uvIndex];
        final vp = plane2[uvIndex];

        int r = (yp + 1.370705 * (vp - 128)).round();
        int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128)).round();
        int b = (yp + 1.732446 * (up - 128)).round();

        buffer.setPixelRgb(
          x,
          y,
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
      }
    }

    return buffer;
  }

  double detectionThreshold = 0.3;

  List<Detection> _parseDetections(List<List<double>> output) {
    List<Detection> results = [];
    for (var row in output) {

       final xCenter = row[0] * 320; // scale from normalized to model input size
        final yCenter = row[1] * 320;
        final width = row[2] * 320;
        final height = row[3] * 320;
        final confidence = row[4];
        final classId = row[5].toInt();
 
       if (confidence > detectionThreshold &&
       !xCenter.isNaN && !yCenter.isNaN &&
       !width.isNaN && !height.isNaN) {
         final w = width.clamp(0.0, 1.0);  // YOLO outputs are normalized [0,1]
         final h = height.clamp(0.0, 1.0);
         final left = (xCenter - w / 2).clamp(0.0, 1.0 - w);
         final top = (yCenter - h / 2).clamp(0.0, 1.0 - h);
 
         // Shrink factor (e.g. 0.9 = 90% size)
         const shrinkFactor = 0.9;
 
         // Compute center
         final centerX = (left + w / 2) * 320.0;
         final centerY = (top + h / 2) * 320.0;
 
         // Shrink width/height
         final scaledW = w * 320.0 * shrinkFactor;
         final scaledH = h * 320.0 * shrinkFactor;
 
         // Re-center the box
         final scaledLeft = centerX - scaledW / 2;
         final scaledTop = centerY - scaledH / 2;
 
         final rect = Rect.fromLTWH(scaledLeft, scaledTop, scaledW, scaledH);
 
         print("Box: x=${rect.left}, y=${rect.top}, w=${rect.width}, h=${rect.height}");
 
          results.add(Detection(
            rect: rect,
            confidence: confidence,
            classId: classId,
          ),
        );
      }
    }
    return results;
  }

  void _pauseCamera() {
    setState(() {
      _isDetecting = false;
      _controller.stopImageStream();
      _isPaused = true;
    });
  }

  void _resumeCamera() {
    setState(() {
      _isDetecting = true;
      _controller.startImageStream((CameraImage image) {
        _frameCount++;
        if (_isDetecting && _frameCount % 30 == 0) {
          _runInference(image);
        }
      });
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller)),
                Positioned.fill(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: BoundingBoxPainter(_detections, 320, 320, _labels),
                  ),
                ),
                if (_isPaused)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Detected: ${_collectedClassIds.join(', ')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_isPaused) {
                          _resumeCamera();
                        } else {
                          _pauseCamera();
                        }
                      });
                    },
                    child: Text(
                      _isPaused ? 'Resume Detection' : 'Pause Detection',
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class Detection {
  final Rect rect;
  final int classId;
  final double confidence;

  Detection({
    required this.rect,
    required this.classId,
    required this.confidence,
  });
}
