
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/ai_chat/domain/entities/chat_message.dart';
import 'package:campus_notify/features/ai_chat/domain/repositories/ai_chat_repository.dart';
import 'package:campus_notify/features/ai_chat/presentation/providers/ai_chat_provider.dart';

class FakeAiChatRepository implements AiChatRepository {
  FakeAiChatRepository({this.shouldFail = false});

  final bool shouldFail;
  int requestCount = 0;

  @override
  Future<void> deleteApiKey() async {}

  @override
  Future<bool> hasApiKey() async => true;

  @override
  Future<void> saveApiKey(String key) async {}

  @override
  Stream<String> streamReply(List<ChatMessage> conversation) async* {
    requestCount++;
    if (shouldFail) throw StateError('network unavailable');
    yield 'Halo ';
    await Future<void>.delayed(Duration.zero);
    yield 'mahasiswa!';
  }
}

void main() {
  test('menggabungkan chunk streaming ke pesan AI', () async {
    final repository = FakeAiChatRepository();
    final container = ProviderContainer(
      overrides: [aiChatRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(aiChatControllerProvider.notifier)
        .sendMessage('Apa itu Flutter?');

    final state = container.read(aiChatControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.messages, hasLength(2));
    expect(state.messages.first.role, ChatRole.user);
    expect(state.messages.last.text, 'Halo mahasiswa!');
  });

  test('pesan kosong tidak memanggil AI API', () async {
    final repository = FakeAiChatRepository();
    final container = ProviderContainer(
      overrides: [aiChatRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(aiChatControllerProvider.notifier).sendMessage('  ');

    expect(repository.requestCount, 0);
    expect(container.read(aiChatControllerProvider).messages, isEmpty);
  });

  test('menyediakan pesan fallback ketika layanan gagal', () async {
    final repository = FakeAiChatRepository(shouldFail: true);
    final container = ProviderContainer(
      overrides: [aiChatRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(aiChatControllerProvider.notifier)
        .sendMessage('Jelaskan database.');

    final state = container.read(aiChatControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Layanan AI sedang bermasalah'));
    expect(state.messages, hasLength(1));
    expect(state.messages.first.role, ChatRole.user);
  });
}
