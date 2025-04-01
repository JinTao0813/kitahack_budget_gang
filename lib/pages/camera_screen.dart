import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'bounding_box_painter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Interpreter _interpreter;
  List<Detection> _detections = [];
  bool _isDetecting = true;
  int _frameCount = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No cameras available");

      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.low);
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
      print("Camera initialization error: $e");
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/yolov8m_float32.tflite', // Ensure this path is correct
      );
      print("Model loaded successfully!");

      // Debugging: Print input and output shapes
      print('Input tensor shape: ${_interpreter.getInputTensor(0).shape}');
      print('Output tensor shape: ${_interpreter.getOutputTensor(0).shape}');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _runInference(CameraImage image) async {
    try {
      final input = await _preprocessImage(image);

      // Allocate correct output shape
      List<List<List<double>>> output = List.generate(
        1,
        (_) => List.generate(84, (_) => List.filled(8400, 0.0)),
      );

      // Run inference
      _interpreter.run(input, output);

      // Transpose [1, 84, 8400] to [8400, 84]
      List<List<double>> transposed = List.generate(
        8400,
        (i) => List.generate(84, (j) => output[0][j][i]),
      );

      final detections = _parseDetections(transposed);

      setState(() {
        _detections = detections;
      });

      // Debugging: Print the number of detections and their details
      print("Detections: ${_detections.length}");
      for (var d in _detections) {
        print(
          "Detected Gesture: Class ${d.classId}, Confidence ${(d.confidence * 100).toStringAsFixed(1)}%",
        );
      }
    } catch (e) {
      print("Inference error: $e");
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
    CameraImage image,
  ) async {
    final img.Image rgbImage = _convertYUV420ToImage(image);
    final resized = img.copyResize(rgbImage, width: 640, height: 640);

    print('Image processed (no save).');

    final input = [
      List.generate(
        640,
        (y) => List.generate(640, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    ];

    return input;
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final imgBuffer = img.Image(width: width, height: height);

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

        imgBuffer.setPixelRgb(
          x,
          y,
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
      }
    }

    return imgBuffer;
  }

  double detectionThreshold = 0.4;

  List<Detection> _parseDetections(List<List<double>> output) {
    List<Detection> results = [];

    for (var row in output) {
      final confidence = row[4];
      if (confidence > detectionThreshold) {
        final x = row[0];
        final y = row[1];
        final w = row[2];
        final h = row[3];

        double maxScore = -1;
        int classId = -1;
        for (int i = 5; i < row.length; i++) {
          if (row[i] > maxScore) {
            maxScore = row[i];
            classId = i - 5;
          }
        }

        results.add(
          Detection(
            rect: Rect.fromLTWH(x, y, w, h),
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      CustomPaint(
                        painter: BoundingBoxPainter(_detections, 640, 640),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_isPaused) {
                  _resumeCamera();
                } else {
                  _pauseCamera();
                }
              });
            },
            child: Text(_isPaused ? 'Resume Detection' : 'Pause Detection'),
          ),
        ],
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
