import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/search_notes.dart';

void main() {
  final notes = [
    Note(title: 'Belanja Mingguan', updatedAt: DateTime(2026, 1, 1)),
    Note(title: 'Catatan Kuliah', updatedAt: DateTime(2026, 1, 2)),
    Note(title: 'Daftar Belanja', updatedAt: DateTime(2026, 1, 3)),
  ];

  test('filter mengabaikan huruf besar/kecil dan mencari sebagian judul', () {
    final result = filterNotesByTitle(notes, 'belanja');
    expect(result, hasLength(2));
    expect(
      result.map((note) => note.title),
      containsAll(['Belanja Mingguan', 'Daftar Belanja']),
    );
  });

  test('query yang tidak cocok mengembalikan list kosong', () {
    expect(filterNotesByTitle(notes, 'zzz-tak-ada'), isEmpty);
  });

  test('query kosong atau spasi mengembalikan semua catatan', () {
    expect(filterNotesByTitle(notes, ' '), hasLength(3));
    expect(filterNotesByTitle(notes, ''), hasLength(3));
  });
}
