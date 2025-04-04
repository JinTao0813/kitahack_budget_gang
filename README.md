# kitahack_budget_gang

An AI-powered Flutter app that bridges communication for the visually and hearing impaired.  
It leverages real-time hand gesture recognition(YOLOv8 which then further converted to TFLite), and Gemini API for speech/sign conversion.

---

## 🚀 Tech Stack

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Google Colab](https://img.shields.io/badge/Google%20Colab-F9AB00?style=for-the-badge&logo=google-colab&logoColor=white)](https://colab.research.google.com/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![TFLite](https://img.shields.io/badge/TFLite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![YOLO](https://img.shields.io/badge/YOLO-00FFFF?style=for-the-badge&logo=github&logoColor=black)](https://docs.ultralytics.com/)
[![Roboflow](https://img.shields.io/badge/Roboflow-101010?style=for-the-badge&logo=roboflow&logoColor=white)](https://roboflow.com/)
[![Gemini API](https://img.shields.io/badge/Gemini%20API-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)

---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to use our app
```bash
git clone https://github.com/JinTao0813/kitahack_budget_gang.git
cd kitahack_budget_gang
  
In Google Colab notebook:
- Remember to change your runtime to python3 and using online GPU
- The public images that collected from online: https://www.kaggle.com/datasets/ayuraj/asl-dataset
- Roboflow annotated public dataset:  https://app.roboflow.com/cecilia-ggvz6/asldetection-o5fgv/2
  
For Flutter:
- The tensorflow model that you are going integrate will be "best_float32.tflite" that was being located in (google_colab_file/best_saved_model (1)/content/runs/detect/train/weights/best_saved_model/best_float32.tflite) folder.
- Please use this to import the tflite flutter so only can use the model inside
  
```bash
import 'package:tflite_flutter/tflite_flutter.dart';




##
  flutter clean
##
  flutter pub get
##
  flutter gen-l10n

After these, you will need a USB cable to connect your Android phone 
* You have to check this side by clicking it (in your VSCODE right hand side lower corner)
 ![image](https://github.com/user-attachments/assets/af27178f-589e-4d2f-acee-edb39d8b726c)
* It will then prompt out this thing
 ![image](https://github.com/user-attachments/assets/c47cfedb-40ef-4827-92c5-be1e9fd4710b)
* Please select the device you are going to run the app
* flutter run // optional, you can run in flutter run --release


