import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart'; // For setLocale() method

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _textController = TextEditingController();
  String _convertedOutput = '';

  void _handleTextConversion() {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _convertedOutput =
          "🖐️ ${loc.convertedOutput}: \"${_textController.text}\"";
    });
  }

  void _handleVoiceInput() {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _convertedOutput = "🎤 ${loc.convertedOutput} (from voice input)";
    });
  }

  void _showFullImage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImageViewerPage()),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🌐 Choose Language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text("🇬🇧", style: TextStyle(fontSize: 20)),
                title: const Text("English"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇨🇳", style: TextStyle(fontSize: 20)),
                title: const Text("中文"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('zh'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇲🇾", style: TextStyle(fontSize: 20)),
                title: const Text("Malay"),
                onTap: () {
                  MyApp.setLocale(context, const Locale('ms'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[100],
        elevation: 20,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.speakOrType,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: loc.speakOrType,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleTextConversion,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _handleVoiceInput,
              icon: const Icon(Icons.mic),
              label: Text(loc.language),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              loc.convertedOutput,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showFullImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/ASL_Alphabet.jpg',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _convertedOutput.isNotEmpty
                        ? _convertedOutput
                        : loc.convertedOutput,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🌍 Bottom sheet style language picker trigger
            ElevatedButton.icon(
              onPressed: () => _showLanguageSheet(context),
              icon: const Icon(Icons.language),
              label: Text(loc.language),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[50],
                foregroundColor: Colors.deepPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Fullscreen image viewer with close button
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 5,
                minScale: 1,
                child: Image.asset('assets/ASL_Alphabet.jpg'),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
