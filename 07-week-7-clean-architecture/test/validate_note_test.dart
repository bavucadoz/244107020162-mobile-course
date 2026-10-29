import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/validate_note.dart';

void main() {
  group('validateNoteTitle', () {
    test('null ditolak', () => expect(validateNoteTitle(null), isNotNull));
    test('string kosong ditolak', () => expect(validateNoteTitle(''), isNotNull));
    test('spasi saja ditolak', () => expect(validateNoteTitle('   '), isNotNull));
    test('judul valid diterima', () => expect(validateNoteTitle('Belanja'), isNull));
  });
}