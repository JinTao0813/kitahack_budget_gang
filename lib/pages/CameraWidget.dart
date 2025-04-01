import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  // Function to initialize camera
  void initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[0], // Select the first camera (usually the back camera)
      ResolutionPreset.high,
    );
    await _controller.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? CameraPreview(_controller) // Display the camera preview
        : const Center(
          child: CircularProgressIndicator(),
        ); // Display a loading spinner while initializing
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
