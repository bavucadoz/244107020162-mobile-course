import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/repositories/gemini_ai_chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  // Dedicated Dio instance: it intentionally has no request-body logger,
  // because prompts and user messages must not be written to debug logs.
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 90),
      headers: const {'Accept': 'text/event-stream'},
    ),
  );
  ref.onDispose(dio.close);

  return GeminiAiChatRepository(
    dio: dio,
    storage: const FlutterSecureStorage(),
  );
});

final aiApiKeyConfiguredProvider = FutureProvider<bool>((ref) {
  return ref.watch(aiChatRepositoryProvider).hasApiKey();
});

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AiChatController extends Notifier<AiChatState> {
  AiChatRepository get _repository => ref.read(aiChatRepositoryProvider);

  @override
  AiChatState build() => const AiChatState();

  Future<void> sendMessage(String input) async {
    final text = input.trim();
    if (text.isEmpty || state.isLoading) return;

    final conversation = [
      ...state.messages,
      ChatMessage(role: ChatRole.user, text: text),
    ];
    await _requestReply(conversation);
  }

  Future<void> retryLastMessage() async {
    if (state.isLoading || !state.messages.any((m) => m.role == ChatRole.user)) {
      return;
    }
    await _requestReply(state.messages);
  }

  Future<void> saveApiKey(String key) => _repository.saveApiKey(key);

  Future<void> removeApiKey() => _repository.deleteApiKey();

  void clearConversation() {
    if (state.isLoading) return;
    state = const AiChatState();
  }

  String _friendlyErrorMessage(Object error) {
    if (error is MissingAiApiKeyException) {
      return 'API key Gemini belum diatur. Ketuk ikon kunci untuk mengaturnya.';
    }
    if (error is GeminiApiException) return error.message;
    if (error is GeminiIncompleteResponseException) {
      return 'Respons Gemini terputus sebelum selesai. Periksa koneksi lalu tekan Coba lagi.';
    }
    if (error is GeminiTruncatedResponseException) {
      if (error.finishReason == 'MAX_TOKENS') {
        return 'Jawaban Gemini mencapai batas token dan terpotong. Coba kirim pertanyaan yang lebih spesifik.';
      }
      if (error.finishReason == 'SAFETY') {
        return 'Gemini menghentikan jawaban karena pemeriksaan keamanan.';
      }
      return 'Gemini menghentikan jawaban sebelum selesai (${error.finishReason}). Silakan coba pertanyaan lain.';
    }
    if (error is FormatException) {
      return 'Respons Gemini tidak dapat dibaca. Periksa format respons API lalu coba lagi.';
    }
    if (error is StateError) {
      return 'Gemini mengembalikan error: ${error.message}';
    }
    if (error is DioException) {
      return 'Koneksi ke Gemini gagal (${error.type.name}). Periksa internet dan coba lagi.';
    }
    return 'Layanan AI gagal diproses (${error.runtimeType}). Periksa koneksi dan coba lagi.';
  }

  Future<void> _requestReply(List<ChatMessage> conversation) async {
    state = state.copyWith(
      messages: [
        ...conversation,
        const ChatMessage(role: ChatRole.model, text: ''),
      ],
      isLoading: true,
      clearError: true,
    );

    final responseBuffer = StringBuffer();
    try {
      await for (final chunk in _repository.streamReply(conversation)) {
        responseBuffer.write(chunk);
        state = state.copyWith(
          messages: [
            ...conversation,
            ChatMessage(role: ChatRole.model, text: normalizeGeminiResponseText(responseBuffer.toString())),
          ],
          isLoading: true,
        );
      }

      final responseText = normalizeGeminiResponseText(responseBuffer.toString()).trim();
      if (responseText.isEmpty) {
        state = state.copyWith(
          messages: [
            ...conversation,
            const ChatMessage(
              role: ChatRole.model,
              text: 'Maaf, AI belum memberikan jawaban. Silakan coba lagi.',
            ),
          ],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(
        messages: conversation,
        isLoading: false,
        errorMessage: _friendlyErrorMessage(error),
      );
    }
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);
