import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/get_notes.dart';
import 'package:campus_notify/features/notes/domain/validate_note.dart';

import '../../../support/fake_note_repository.dart';

void main() {
  group('GetNotes', () {
    test('meneruskan daftar catatan dari repository', () async {
      // Arrange
      final expectedNote = Note(
        id: 1,
        title: 'Belajar Flutter',
        updatedAt: DateTime(2026, 11, 15),
      );
      final repository = FakeNoteRepository(initialNotes: [expectedNote]);
      final useCase = GetNotes(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.failure, isNull);
      expect(result.notes, [expectedNote]);
      expect(repository.fetchCallCount, 1);
    });

    test('meneruskan kegagalan repository kepada pemanggil', () async {
      final repository = FakeNoteRepository(
        fetchError: 'Database tidak dapat dibuka',
      );

      final useCase = GetNotes(repository);

      final result = await useCase();

      expect(result.notes, isEmpty);
      expect(result.failure, isA<LocalFailure>());
      expect(result.failure!.message, contains('Database'));
    });
  });

  group('SaveNote', () {
    test('menolak judul kosong tanpa memanggil repository', () async {
      final repository = FakeNoteRepository();
      final useCase = SaveNote(repository);
      final invalidNote = Note(
        title: '   ',
        updatedAt: DateTime(2026, 11, 15),
      );

      await expectLater(
        useCase(invalidNote),
        throwsA(isA<NoteValidationException>()),
      );

      expect(repository.lastSavedNote, isNull);
    });

    test('meneruskan catatan valid ke repository', () async {
      final repository = FakeNoteRepository();
      final note = Note(
        id: 7,
        title: 'Tugas Pengujian',
        body: 'Membuat unit test',
        updatedAt: DateTime(2026, 11, 15),
      );

      final useCase = SaveNote(repository);

      await useCase(note);

      expect(repository.lastSavedNote, same(note));
    });
  });
}
