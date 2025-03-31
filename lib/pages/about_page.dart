import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('About'),
          centerTitle: true,
          backgroundColor: Colors.deepPurple[100],
          elevation: 20,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('About Page', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
