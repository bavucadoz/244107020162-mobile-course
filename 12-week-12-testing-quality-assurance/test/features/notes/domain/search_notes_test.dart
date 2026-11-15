import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/search_notes.dart';

void main() {
  final notes = [
    Note(
      id: 1,
      title: 'Belajar Flutter',
      body: 'State management',
      updatedAt: DateTime(2026, 11, 1),
    ),
    Note(
      id: 2,
      title: 'Metodologi Penelitian',
      body: 'Rancangan penelitian',
      updatedAt: DateTime(2026, 11, 2),
    ),
    Note(
      id: 3,
      title: 'Praktikum Database',
      body: 'SQL dan relasi',
      updatedAt: DateTime(2026, 11, 3),
    ),
  ];

  group('filterNotesByTitle', () {
    test('mengembalikan semua catatan saat query kosong', () {
      expect(filterNotesByTitle(notes, ''), same(notes));
    });

    test('mengembalikan semua catatan saat query hanya spasi', () {
      expect(filterNotesByTitle(notes, '   '), same(notes));
    });

    test('mencari judul tanpa membedakan huruf besar dan kecil', () {
      final result = filterNotesByTitle(notes, 'fLuTtEr');

      expect(result, hasLength(1));
      expect(result.single.title, 'Belajar Flutter');
    });

    test('mengabaikan spasi di awal dan akhir query', () {
      final result = filterNotesByTitle(notes, '  database  ');

      expect(result, hasLength(1));
      expect(result.single.title, 'Praktikum Database');
    });

    test('mendukung pencarian sebagian judul', () {
      final result = filterNotesByTitle(notes, 'Penelitian');

      expect(result.map((note) => note.id).toList(), [2]);
    });

    test('mengembalikan list kosong jika tidak ada hasil', () {
      expect(filterNotesByTitle(notes, 'Fisika Kuantum'), isEmpty);
    });
  });
}
