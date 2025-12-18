import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:paypulse/core/errors/exceptions.dart';

class GeminiProvider {
  final String? _apiKey;
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  GeminiProvider({String? apiKey}) : _apiKey = apiKey;

  Future<String> generateText(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw const ServerException(message: 'Gemini API key not configured');
    }

    try {
      // Using gemini-1.5-flash for efficiency
      final response = await http.post(
        Uri.parse('$_baseUrl/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw ServerException(
          message:
              'Gemini API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to generate text: $e');
    }
  }
}
