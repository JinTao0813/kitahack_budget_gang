# kitahack_budget_gang

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Object Detection Model
For the object detection model, it was being train with YOLOv8 in Google Colab and being convert into TFLite model
Things to justify is:
In Google Colab notebook:
-Remember to change your runtime to python3 and using online GPU
-The public images that I collected from online: https://www.kaggle.com/datasets/ayuraj/asl-dataset
-Roboflow annotated public dataset: https://app.roboflow.com/cecilia-ggvz6/asldetection-o5fgv/1
For Flutter:
- the tensorflow model that you are going integrate will be "yolov8m_float32.tflite" that was being located in (google_colab_file/yolov8m_saved_model/content/yolov8m_saved_model) folder.
-Please use import 'package:tflite_flutter/tflite_flutter.dart'; to import the tflite flutter so only can use the model inside
 


