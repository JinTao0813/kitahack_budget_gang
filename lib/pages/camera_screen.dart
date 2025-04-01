import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel(); // Load the model during initialization
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras available");
      }

      final firstCamera = cameras.first; // Select the first available camera
      _controller = CameraController(firstCamera, ResolutionPreset.medium);

      // Start image stream to continuously get frames
      _controller.startImageStream((CameraImage image) {
        _frameCount++;
        // Only run inference if _isDetecting is true and every 5th frame
        if (_isDetecting && _frameCount % 5 == 0) {
          _runInference(image);
        }
      });

      // Wait for camera to initialize
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      // Load the TensorFlow Lite model
      _interpreter = await Interpreter.fromAsset(
        'assets/handgesture_model.tflite',
      ); // Make sure this path is correct
      print("Model loaded successfully!");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Run inference on the captured image
  Future<void> _runInference(CameraImage image) async {
    try {
      final input = await _preprocessImage(image); // Preprocess the image
      var output = List.generate(
        1,
        (_) => List.generate(
          100,
          (_) => List.filled(6, 0.0),
        ), // Assuming model outputs 100 detections with 6 values each (x, y, w, h, confidence, class)
      );

      _interpreter.run(input, output); // Run inference

      final detections = _parseDetections(output[0]);

      setState(() {
        _detections = detections;
      });
      print("Detections: ${_detections.length}"); // Debugging output
    } catch (e) {
      print("Inference error: $e");
    }
  }

  // Preprocess the image (resize, normalize, etc.)
  Future<List<List<List<List<double>>>>> _preprocessImage(
    CameraImage image,
  ) async {
    final img.Image rgbImage = _convertYUV420ToImage(image);

    // Resize the image to 640x640, which is standard for YOLOv8 models
    final resized = img.copyResize(
      rgbImage,
      width: 640,
      height: 640,
    ); // Resize image to match YOLO's input size

    // Normalize pixel values to be between 0 and 1 (model training likely used this normalization)
    final input = [
      List.generate(
        640,
        (y) => List.generate(640, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0, // Normalize Red channel
            pixel.g / 255.0, // Normalize Green channel
            pixel.b / 255.0, // Normalize Blue channel
          ];
        }),
      ),
    ];

    return input;
  }

  // Convert YUV420 image to RGB
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

  List<Detection> _parseDetections(List<List<double>> output) {
    const threshold =
        0.3; // Lower threshold to detect gestures with lower confidence
    List<Detection> results = [];

    for (var i = 0; i < output.length; i++) {
      final row = output[i];
      final confidence = row[4]; // Confidence score
      if (confidence > threshold) {
        final x = row[0];
        final y = row[1];
        final w = row[2];
        final h = row[3];
        final classId = row[5].toInt(); // Class ID

        results.add(
          Detection(
            rect: Rect.fromLTWH(
              x - w / 2,
              y - h / 2,
              w,
              h,
            ), // Bounding box coordinates
            classId: classId, // Class ID (hand gesture class)
            confidence: confidence, // Confidence score
          ),
        );

        // Debugging: print class ID and confidence
        print("Detected class: $classId, Confidence: ${confidence * 100}%");
      }
    }

    return results;
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_isDetecting) {
                  _isDetecting = false; // Pause inference
                } else {
                  _isDetecting = true; // Resume inference
                }
              });
            },
            child: Text(_isDetecting ? 'Pause Detection' : 'Resume Detection'),
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
