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
  late Future<void>
  _initializeControllerFuture; // This future will be used to check initialization
  late Interpreter _interpreter;
  List<Detection> _detections = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize the camera controller here
    _loadModel(); // Load the TensorFlow Lite model here
  }

  // Initialize the camera controller
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras available");
      }

      final firstCamera = cameras.first; // Select the first available camera
      _controller = CameraController(firstCamera, ResolutionPreset.medium);

      // Wait for the camera to be initialized
      _initializeControllerFuture = _controller.initialize();
      setState(() {}); // Ensure the UI is rebuilt after initialization
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/yolov8m_float32.tflite');
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
        future:
            _initializeControllerFuture, // Ensure that the camera is initialized
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the camera is initialized, show the preview
            return CameraPreview(_controller);
          } else if (snapshot.hasError) {
            // If there's an error, show the error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Otherwise, show a loading spinner while waiting for initialization
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
