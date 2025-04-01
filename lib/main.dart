import 'package:flutter/material.dart';
import 'package:kitahack_budget_gang/pages/home_page.dart'; // Import HomePage
import 'package:kitahack_budget_gang/pages/camera_screen.dart'; // Import CameraScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), // Use HomePage as the starting screen
      // Define routes
      routes: {
        '/home': (context) => const HomePage(),
        '/camera':
            (context) => const CameraScreen(), // Ensure CameraScreen route
      },
    );
  }
}
