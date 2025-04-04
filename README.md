# kitahack_budget_gang

---
## 📱About
---

#### SeeSpeak is an AI-powered Flutter app that bridges communication for the visually and hearing impaired.  
It leverages real-time hand gesture recognition(YOLOv8 which then further converted to TFLite), and Gemini API for speech/sign conversion.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Google Colab](https://img.shields.io/badge/Google%20Colab-F9AB00?style=for-the-badge&logo=google-colab&logoColor=white)](https://colab.research.google.com/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![TFLite](https://img.shields.io/badge/TFLite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![YOLO](https://img.shields.io/badge/YOLO-00FFFF?style=for-the-badge&logo=github&logoColor=black)](https://docs.ultralytics.com/)
[![Roboflow](https://img.shields.io/badge/Roboflow-101010?style=for-the-badge&logo=roboflow&logoColor=white)](https://roboflow.com/)
[![Gemini API](https://img.shields.io/badge/Gemini%20API-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)

---
## 🤩 Features

| 🚀 Feature                              | 💡 Description                                                                 |
|----------------------------------------|--------------------------------------------------------------------------------  |
| 🧤 Real-time Gesture Recognition        | Detects and classifies hand signs using a YOLOv8 TFLite model                  |
| 🎤 Voice/Text-to-Sign Language Conversion    | Converts spoken words or text into signs or text using Gemini API                      |
| 📸 Custom Camera Overlay                | Displays bounding boxes over detected hands in real-time                       |
| 🔄 On-device AI Inference               | Runs TFLite models locally without internet for fast and secure predictions    |
| 🌐 Gemini API Integration               | Enables natural language processing and AI-generated responses                 |
| 🧪 Trained with Roboflow + Google Colab | Seamless training pipeline for detection models using YOLOv8 and TFLite        |
| 📱 Mobile-optimized Interface           | Clean, accessible UI designed for visually and hearing impaired users          |

---
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Prerequisites

- Flutter SDK version 3.29.2
- Dart 3.7.2
- IDE (VS Code)
- AI training : Google Colab, Yolov8
- Image annotation: Roboflow

## How to use our app
1. Clone Repository
```bash
git clone https://github.com/JinTao0813/kitahack_budget_gang.git
```
```bash
cd kitahack_budget_gang
```
2. Install Dependencies
```bash
  flutter pub get
```
```bash
  flutter gen-l10n
```
3. Run the app
```bash
  flutter run
  or optionally you can run flutter run --release
```
## Google Colab notebook for training AI model:
- Remember to change your runtime to python3 and using online GPU
- The public images that collected from online: https://www.kaggle.com/datasets/ayuraj/asl-dataset
- Roboflow annotated public dataset:  https://app.roboflow.com/cecilia-ggvz6/asldetection-o5fgv/2
## To see the full code on how to run:

```bash
https://colab.research.google.com/drive/15D9tFl1uxaIz92AXmjFSEZ5uxraCB9qn?usp=sharing
```
After everything run finished and you got the zip folder, for us we placed it under the google_colab_file

For Flutter:
- The tensorflow model that you are going integrate will be "best_float32.tflite" that was being located in (google_colab_file/best_saved_model (1)/content/runs/detect/train/weights/best_saved_model/best_float32.tflite) folder.
- Please use this to import the tflite flutter so only can use the model inside
  
```bash
import 'package:tflite_flutter/tflite_flutter.dart';
```
After these, you will need a USB cable to connect your Android phone 
* You have to check this side by clicking it (in your VSCODE right hand side lower corner)
  
 ![image](https://github.com/user-attachments/assets/af27178f-589e-4d2f-acee-edb39d8b726c)
 
* It will then prompt out this thing
  
 ![image](https://github.com/user-attachments/assets/c47cfedb-40ef-4827-92c5-be1e9fd4710b)

* Please select the device you are going to run the app
* flutter run // optional, you can run in flutter run --release

## 🛠️ Tech Stack

| Category           | Technologies                                              | Purpose                                                                 |
|--------------------|-----------------------------------------------------------|-------------------------------------------------------------------------|
| **Framework**       | Flutter & Dart                                           | Cross-platform mobile UI development                                    |
| **Model Training**  | YOLOv8, Roboflow, Google Colab                           | Object and gesture detection training & TFLite conversion               |
| **AI Integration**  | TensorFlow Lite, Gemini API                              | Real-time on-device inference & speech/sign conversion                  |
| **Camera & Vision** | Flutter Camera, Custom Overlay                           | Capturing frames and drawing detection boxes                            |
| **Networking**      | Gemini API (via HTTP)                                    | Connecting to Google AI services for language interpretation            |
| **UI Enhancement**  | Material Icons, Animations                               | Intuitive user experience and animated feedback                         |
| **Utilities**       | Path Provider                                            | File system access                                                      |


## 🎉Outcomes
(Mine is old phone with old screen protector and that's why you see the linings, so no worries! The app itself is fine!)

![image](https://github.com/user-attachments/assets/20f35cd8-55cb-4026-98f2-5c37966c05d1)

![image](https://github.com/user-attachments/assets/095948f6-b323-4ffe-bb70-f3523de8bb0f)

![image](https://github.com/user-attachments/assets/47097284-005d-478d-bd36-b44f2e40493c)

![image](https://github.com/user-attachments/assets/484c0048-4dd6-4b2b-8411-3f778806826b)






