import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/ai_chat/data/repositories/gemini_ai_chat_repository.dart';

void main() {
  group('extractGeminiText', () {
    test('mengambil teks dari response chunk Gemini', () {
      final result = extractGeminiText({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Halo '},
                {'text': 'mahasiswa!'},
              ],
            },
          },
        ],
      });

      expect(result, 'Halo mahasiswa!');
    });

    test('mengembalikan null jika chunk tidak memiliki teks', () {
      expect(extractGeminiText({'candidates': []}), isNull);
      expect(extractGeminiText({'usageMetadata': {'totalTokenCount': 10}}), isNull);
    });

    test('menghasilkan error jika API mengirim payload error', () {
      expect(
        () => extractGeminiText({
          'error': {'message': 'API key invalid'},
        }),
        throwsA(isA<StateError>()),
      );
    });
  });
}
