import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final List<Map<String, String>> teamMembers = const [
    {'name': 'Gan Zhi Yun', 'image': 'assets/gan.png'},
    {'name': 'Wong Loo Perth', 'image': 'assets/wong.png'},
    {'name': 'Tan Ray Xiang', 'image': 'assets/tan.png'},
    {'name': 'Yap Jin Tao', 'image': 'assets/yap.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[100],
        elevation: 20,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'Kitahack 2025 - Budget Gang',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...teamMembers.map(
            (member) => FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      member['image']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    member['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Team Member - Kitahack Budget Gang'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
