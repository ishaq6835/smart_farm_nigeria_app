import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<Map<String, dynamic>> diagnose({
    required Uint8List imageBytes,
    required String cropName,
    int maxAttempts = 3,
  }) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _diagnoseOnce(imageBytes: imageBytes, cropName: cropName);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (attempt < maxAttempts) {
          // Short delay before retrying — helps ride out brief server
          // overload ("model is currently experiencing high demand") or
          // a momentary network hiccup, common on mobile connections.
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw lastError ?? Exception('Gemini diagnosis failed after $maxAttempts attempts.');
  }

  static Future<Map<String, dynamic>> _diagnoseOnce({
    required Uint8List imageBytes,
    required String cropName,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Check your .env file.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey',
    );

    final base64Image = base64Encode(imageBytes);

    final prompt = '''
You are an agricultural plant pathologist. Look at this $cropName leaf photo.
Reply ONLY in this exact JSON format, nothing else, no markdown, no code fences:
{
  "condition": "name of disease, or Healthy",
  "confidence": 0.0 to 1.0,
  "symptoms": "short description of what you see",
  "treatment": "short practical treatment advice for a Nigerian smallholder farmer"
}
If the image is not a $cropName leaf, or is too unclear/blurry to diagnose, set "condition" to "Unclear Image".
''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image,
                }
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);

    String text;
    try {
      text = data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      throw Exception('Unexpected Gemini response format: ${response.body}');
    }

    // Strip markdown code fences in case Gemini wraps the JSON despite instructions
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Could not parse Gemini response as JSON: $text');
    }
  }
}