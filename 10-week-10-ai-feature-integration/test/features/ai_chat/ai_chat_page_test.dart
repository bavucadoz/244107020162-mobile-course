import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/ai_chat/domain/entities/chat_message.dart';
import 'package:campus_notify/features/ai_chat/domain/repositories/ai_chat_repository.dart';
import 'package:campus_notify/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:campus_notify/features/ai_chat/presentation/providers/ai_chat_provider.dart';

class FakeAiChatRepository implements AiChatRepository {
  String? savedApiKey;

  @override
  Future<void> deleteApiKey() async {}

  @override
  Future<bool> hasApiKey() async => false;

  @override
  Future<void> saveApiKey(String key) async {
    savedApiKey = key;
  }

  @override
  Stream<String> streamReply(List<ChatMessage> conversation) async* {
    yield 'Ini jawaban simulasi CampusMate.';
  }
}

void main() {
  Widget createTestApp(FakeAiChatRepository repository) {
    return ProviderScope(
      overrides: [
        aiChatRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: AiChatPage()),
    );
  }

  testWidgets('menampilkan welcome state dan peringatan privasi', (tester) async {
    await tester.pumpWidget(createTestApp(FakeAiChatRepository()));

    expect(find.text('Halo, saya CampusMate!'), findsOneWidget);
    expect(find.textContaining('Jangan kirim NIK'), findsOneWidget);
    expect(find.byKey(const Key('ai-chat-input')), findsOneWidget);
  });

  testWidgets('mengirim pesan dan menampilkan respons AI', (tester) async {
    await tester.pumpWidget(createTestApp(FakeAiChatRepository()));

    await tester.enterText(
      find.byKey(const Key('ai-chat-input')),
      'Apa manfaat belajar Flutter?',
    );
    await tester.tap(find.byKey(const Key('ai-send-button')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Apa manfaat belajar Flutter?'), findsOneWidget);
    expect(find.text('Ini jawaban simulasi CampusMate.'), findsOneWidget);
  });

  testWidgets('menyimpan API key setelah dialog ditutup', (tester) async {
    final repository = FakeAiChatRepository();
    await tester.pumpWidget(createTestApp(repository));

    await tester.tap(find.byKey(const Key('ai-settings-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gemini-api-key-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('gemini-api-key-field')),
      'GEMINI_TEST_KEY',
    );
    await tester.tap(find.byKey(const Key('save-gemini-api-key-button')));
    await tester.pumpAndSettle();

    expect(repository.savedApiKey, 'GEMINI_TEST_KEY');
    expect(find.text('API key berhasil disimpan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
