import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart'; // Sesuaikan path file model Anda

void main() {
  group('Comment Model Test', () {
    test('EdgeTest: fromJson harus memberikan nilai fallback aman ketika field missing atau null', () {
      // 1. Arrange: Buat payload JSON parsial dengan field null / hilang
      final Map<String, dynamic> incompleteJson = {
        'id': 101,
        'postId': null,
        // 'name' sengaja dihilangkan
        'email': null,
        // 'body' sengaja dihilangkan
      };

      // 2. Act: Panggil factory constructor fromJson
      final comment = Comment.fromJson(incompleteJson);

      // 3. Assert: Verifikasi bahwa tidak terjadi Crash dan default fallback berhasil diterapkan
      expect(comment.id, equals(101));
      expect(comment.postId, equals(0));      // Fallback null int ke 0
      expect(comment.name, equals(''));       // Fallback missing String ke ''
      expect(comment.email, equals(''));      // Fallback null String ke ''
      expect(comment.body, equals(''));       // Fallback missing String ke ''
    });
  });
}