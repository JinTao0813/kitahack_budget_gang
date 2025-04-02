import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyCe5DOcmwytSxHTWl2AziqUjez51H-cufE';

  Future<String> getASLInfo(int? number) async {
    final prompt =
        number != null
            ? "Explain the American Sign Language (ASL) gesture for the number $number. Keep it short and simple."
            : "Explain how American Sign Language (ASL) hand signs work in general. Include examples of how numbers are shown using fingers.";

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-001:generateContent?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        print("❌ Gemini API error: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return "Failed to fetch ASL info from Gemini.";
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      return "An error occurred while contacting Gemini.";
    }
  }
}
