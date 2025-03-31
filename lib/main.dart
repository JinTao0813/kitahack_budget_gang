import 'package:flutter/material.dart';
import 'package:kitahack_budget_gang/pages/home_page.dart';
import 'package:kitahack_budget_gang/pages/settings_page.dart';
import 'package:kitahack_budget_gang/pages/about_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
