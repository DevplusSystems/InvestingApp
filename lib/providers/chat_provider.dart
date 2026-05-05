import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

// AI Service Provider
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
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
  final AiService _aiService;

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
      // Create empty assistant message for streaming
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
      );

      String fullResponse = '';

      // Stream AI response
      await for (final chunk in _aiService.sendMessage(message)) {
        fullResponse += chunk;
        
        // Update the last assistant message
        final updatedMessages = List<ChatMessage>.from(state.messages);
        updatedMessages[updatedMessages.length - 1] = updatedMessages.last.copyWith(
          content: fullResponse,
        );

        state = state.copyWith(messages: updatedMessages);
      }

      // Mark streaming as complete
      final finalMessages = List<ChatMessage>.from(state.messages);
      finalMessages[finalMessages.length - 1] = finalMessages.last.copyWith(
        isStreaming: false,
      );

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
