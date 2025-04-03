import 'package:flutter/material.dart';
import 'package:kitahack_budget_gang/pages/settings_page.dart';
import 'package:kitahack_budget_gang/pages/about_page.dart';
import 'package:kitahack_budget_gang/pages/camera_screen.dart';
import 'package:kitahack_budget_gang/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _aslInfo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGeminiInfo(null); // Load default ASL info on startup
  }

  void _navigateBottomNavBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _fetchGeminiInfo(List<int>? classIds) async {
    setState(() {
      _isLoading = true;
    });

    final gemini = GeminiService();
    final info = await gemini.getASLInfo(classIds);

    setState(() {
      _aslInfo = info;
      _isLoading = false;
      _selectedIndex = 0; // Automatically return to Home tab
    });
  }

  List<Widget> _pages() => [
    SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤟ASL Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_aslInfo.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.deepPurple[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: MarkdownBody(
                  data: _aslInfo,
                  styleSheet: MarkdownStyleSheet.fromTheme(
                    Theme.of(context),
                  ).copyWith(
                    p: const TextStyle(fontSize: 16, height: 1.5),
                    h2: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    listBullet: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          else
            const Text(
              'No ASL info yet. Use the camera to detect a sign.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    ),
    const SettingsPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
              centerTitle: true,
              backgroundColor: Colors.deepPurple[100],
              elevation: 20,
            ),
            body: _pages()[0],
          ),
          _pages()[1],
          _pages()[2],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CameraScreen(
                    onDetected: (List<int> classIds) {
                      _fetchGeminiInfo(classIds); // 🔁 Pass whole list
                    },
                  ),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
        backgroundColor: Colors.deepPurple[200],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlue[50],
        currentIndex: _selectedIndex,
        onTap: _navigateBottomNavBar,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}
