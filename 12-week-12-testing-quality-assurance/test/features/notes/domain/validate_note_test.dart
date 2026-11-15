import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/validate_note.dart';

void main() {
  group('validateNoteTitle', () {
    test('menolak nilai null', () {
      // Arrange
      const String? title = null;

      // Act
      final result = validateNoteTitle(title);

      // Assert
      expect(result, 'Judul tidak boleh kosong');
    });

    test('menolak string kosong', () {
      expect(validateNoteTitle(''), 'Judul tidak boleh kosong');
    });

    test('menolak teks yang hanya berisi spasi', () {
      expect(validateNoteTitle('   \t  '), 'Judul tidak boleh kosong');
    });

    test('menerima judul yang berisi teks', () {
      expect(validateNoteTitle('Belajar Flutter'), isNull);
    });

    test('menerima teks dengan spasi di sekelilingnya', () {
      // Validasi hanya memastikan ada teks; pemangkasan dilakukan oleh UI.
      expect(validateNoteTitle('  Catatan kuliah  '), isNull);
    });
  });
}
