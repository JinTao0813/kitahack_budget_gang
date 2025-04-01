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
  List<Detection> _detections =
      []; // This will still be updated, but we won't show it for now

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;

    // Start the image stream for real-time inference
    _controller.startImageStream((CameraImage image) async {
      await _runInference(image); // Perform inference on each image frame
    });
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/yolov8m_float32.tflite');
  }

  // Run inference
  Future<void> _runInference(CameraImage image) async {
    try {
      final input = await _preprocessImage(image); // Preprocess the image
      var output = List.generate(
        1,
        (_) => List.generate(100, (_) => List.filled(6, 0.0)),
      ); // Initialize output

      // Run inference
      _interpreter.run(input, output);

      final detections = _parseDetections(
        output[0],
      ); // Parse the output into detection objects

      setState(() {
        _detections =
            detections; // Update the list of detections (but we won't show it yet)
      });
    } catch (e) {
      print("Inference error: $e");
    }
  }

  // Image preprocessing function (resize, normalize, etc.)
  Future<List<List<List<List<double>>>>> _preprocessImage(
    CameraImage image,
  ) async {
    final img.Image rgbImage = _convertYUV420ToImage(
      image,
    ); // Convert YUV to RGB
    final resized = img.copyResize(
      rgbImage,
      width: 640,
      height: 640,
    ); // Resize the image

    final input = [
      List.generate(
        640,
        (y) => List.generate(640, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ]; // Normalize pixel values
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

  // Parse the detections from the model's output
  List<Detection> _parseDetections(List<List<double>> output) {
    const threshold = 0.4;
    List<Detection> results = [];

    for (var i = 0; i < output.length; i++) {
      final row = output[i];
      final confidence = row[4];
      if (confidence > threshold) {
        final x = row[0];
        final y = row[1];
        final w = row[2];
        final h = row[3];
        final classId = row[5].toInt();

        results.add(
          Detection(
            rect: Rect.fromLTWH(x - w / 2, y - h / 2, w, h),
            classId: classId,
            confidence: confidence,
          ),
        );
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
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, // Await the initialization
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Once the camera is initialized, show the camera preview
            return CameraPreview(_controller);
          } else if (snapshot.hasError) {
            // Handle errors if the future fails
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // While the camera is initializing, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class Detection {
  final Rect rect; // Bounding box coordinates
  final int classId; // Class ID of the detected object
  final double confidence; // Confidence of the detection

  Detection({
    required this.rect,
    required this.classId,
    required this.confidence,
  });
}
