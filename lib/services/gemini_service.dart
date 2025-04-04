import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = ''; //please put your own api key in the ''

  Future<String> getASLInfo(List<int>? numbers) async {
    final prompt =
        (numbers != null && numbers.isNotEmpty)
            ? "Provide detailed explanations of the American Sign Language (ASL) hand gestures for the numbers: ${numbers.join(', ')}. For each number, describe the hand shape, finger positions, and any relevant movement or orientation. Format the explanation clearly and make it informative."
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
        final candidates = data['candidates'];
        if (candidates != null &&
            candidates is List &&
            candidates.isNotEmpty &&
            candidates[0]['content']?['parts']?[0]?['text'] != null) {
          return candidates[0]['content']['parts'][0]['text'];
        } else {
          print("⚠️ Gemini response structure missing expected fields.");
          print("📦 Response JSON: ${jsonEncode(data)}");
          return "Gemini returned an unexpected response format.";
        }
      } else if (response.statusCode == 429) {
        print("❌ Gemini quota exceeded (429).");
        print("💡 Check: https://ai.google.dev/gemini-api/docs/rate-limits");
        return "🚫 Gemini API quota exceeded. Please try again tomorrow or check your usage at https://ai.google.dev. Detected numbers: ${numbers?.join(', ')}";
      } else {
        print("❌ Gemini API error: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return "Failed to fetch ASL info from Gemini (Status: ${response.statusCode}).";
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      return "An exception occurred while contacting Gemini: $e";
    }
  }
}
