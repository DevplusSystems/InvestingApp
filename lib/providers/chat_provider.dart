import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// Chat State
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Chat Provider
class ChatNotifier extends StateNotifier<ChatState> {
  final AIService _aiService;

  ChatNotifier(this._aiService) : super(ChatState());

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: message,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final responseText = await _aiService.sendMessage(message);

      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: responseText,
        timestamp: DateTime.now(),
      );

      final finalMessages = [...state.messages, assistantMessage];

      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    _aiService.clearHistory();
    state = ChatState();
  }

  void retryLastMessage() {
    if (state.messages.isEmpty) return;

    final lastUserMessage = state.messages
        .where((msg) => msg.role == MessageRole.user)
        .last;

    // Remove the last assistant message if it exists
    final messages = List<ChatMessage>.from(state.messages);
    if (messages.isNotEmpty && messages.last.role == MessageRole.assistant) {
      messages.removeLast();
    }

    state = state.copyWith(messages: messages);

    // Resend the user message
    sendMessage(lastUserMessage.content);
  }
}

// Chat Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return ChatNotifier(aiService);
});
