import 'package:flutter/material.dart';
import 'package:kitahack_budget_gang/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), // Start with HomePage
      routes: {
        '/home': (context) => const HomePage(), // ✅ Only keep valid routes
      },
    );
  }
}
