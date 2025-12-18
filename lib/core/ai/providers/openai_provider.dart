import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:paypulse/core/errors/exceptions.dart';

class OpenAIProvider {
  final String? _apiKey;
  final String _baseUrl = 'https://api.openai.com/v1';

  OpenAIProvider({String? apiKey}) : _apiKey = apiKey;

  Future<String> generateText(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw const ServerException(message: 'OpenAI API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw ServerException(
          message:
              'OpenAI API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to generate text: $e');
    }
  }
}
