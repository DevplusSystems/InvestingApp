import 'dart:async';
import 'package:openai_dart/openai_dart.dart';
import '../config/api_config.dart';
import '../models/chat_message.dart';

class AiService {
  late final OpenAIClient _client;
  final List<ChatMessage> _conversationHistory = [];

  AiService() {
    _client = OpenAIClient(
      apiKey: ApiConfig.openaiApiKey,
      baseUrl: 'https://api.openai.com/v1',
    );
  }

  // System prompt for Iris - the investment assistant
  static const String _systemPrompt = '''You are Iris, an intelligent investment assistant. You help users with:
- Stock market analysis and insights
- Portfolio recommendations
- Investment strategies
- Financial market trends
- Risk assessment

Provide clear, concise, and well-reasoned responses. Always include appropriate disclaimers that your advice is for informational purposes only and not financial advice.''';

  Stream<String> sendMessage(String userMessage) async* {
    // Add user message to history
    final userChatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: userMessage,
      timestamp: DateTime.now(),
    );
    _conversationHistory.add(userChatMessage);

    // Build messages for API
    final messages = [
      ChatMessage(
        id: 'system',
        role: MessageRole.system,
        content: _systemPrompt,
        timestamp: DateTime.now(),
      ),
      ..._conversationHistory,
    ];

    // Convert to OpenAI format
    final openAiMessages = messages.map((msg) {
      return ChatCompletionMessage(
        role: switch (msg.role) {
          MessageRole.user => ChatCompletionMessageRole.user,
          MessageRole.assistant => ChatCompletionMessageRole.assistant,
          MessageRole.system => ChatCompletionMessageRole.system,
        },
        content: ChatCompletionMessageContent.text(msg.content),
      );
    }).toList();

    try {
      // Create streaming request
      final stream = _client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: ApiConfig.openaiModel,
          messages: openAiMessages,
          temperature: 0.7,
          maxTokens: 1000,
        ),
      );

      String fullResponse = '';
      
      await for (final chunk in stream) {
        final delta = chunk.choices.first.delta;
        if (delta.content != null) {
          final content = delta.content!;
          fullResponse += content;
          yield content;
        }
      }

      // Add assistant response to history
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: fullResponse,
        timestamp: DateTime.now(),
      );
      _conversationHistory.add(assistantMessage);

    } catch (e) {
      yield 'Error: $e';
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
  }

  List<ChatMessage> getConversationHistory() {
    return List.unmodifiable(_conversationHistory);
  }
}
