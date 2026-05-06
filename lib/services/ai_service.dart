import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AIService {
  AIService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> sendMessage(String message) async {
    final apiKey = ApiConfig.openaiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY') {
      return 'OpenAI API key is not configured.';
    }

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': ApiConfig.openaiModel,
        'messages': [
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OpenAI request failed (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = (decoded['choices'] as List?) ?? const [];
    if (choices.isEmpty) return 'No response';

    final messageObj = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
    final content = messageObj?['content'];
    return (content is String && content.trim().isNotEmpty) ? content : 'No response';
  }

  void clearHistory() {
    // No-op for now (hook up persisted history later).
  }
}
