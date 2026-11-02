import '../entities/chat_message.dart';

abstract interface class AiChatRepository {
  Future<bool> hasApiKey();
  Future<void> saveApiKey(String key);
  Future<void> deleteApiKey();
  Stream<String> streamReply(List<ChatMessage> conversation);
}

class MissingAiApiKeyException implements Exception {
  const MissingAiApiKeyException();

  @override
  String toString() => 'API key Gemini belum diatur.';
}
