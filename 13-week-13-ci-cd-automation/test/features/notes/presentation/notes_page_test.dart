import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/presentation/pages/note_page.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';

import '../../../support/fake_note_repository.dart';

void main() {
  Widget createTestApp(FakeNoteRepository repository) {
    return ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: NotesPage()),
    );
  }

  Note createNote({
    required int id,
    required String title,
    String body = '',
  }) {
    return Note(
      id: id,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 11, 15),
      dirty: true,
    );
  }

  group('NotesPage', () {
    testWidgets('menampilkan daftar catatan saat data tersedia', (
      tester,
    ) async {
      final repository = FakeNoteRepository(
        initialNotes: [
          createNote(
            id: 1,
            title: 'Belajar Flutter',
            body: 'Mempelajari widget test',
          ),
        ],
      );

      await tester.pumpWidget(createTestApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Catatan Offline'), findsOneWidget);
      expect(find.text('Belajar Flutter'), findsOneWidget);
      expect(find.text('Mempelajari widget test'), findsOneWidget);
    });

    testWidgets('menampilkan empty state saat belum ada catatan', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(FakeNoteRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada catatan.'), findsOneWidget);
    });

    testWidgets('menampilkan pesan validasi jika judul kosong', (
      tester,
    ) async {
      final repository = FakeNoteRepository();

      await tester.pumpWidget(createTestApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-note-button')));
      await tester.pumpAndSettle();

      expect(find.text('Judul catatan wajib diisi.'), findsOneWidget);
      expect(repository.addCallCount, 0);
    });

    testWidgets('menambahkan catatan setelah input valid', (tester) async {
      final repository = FakeNoteRepository();

      await tester.pumpWidget(createTestApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('note-title-field')),
        'Rangkuman Metopen',
      );
      await tester.enterText(
        find.byKey(const Key('note-body-field')),
        'Menyusun rancangan metode penelitian.',
      );
      await tester.tap(find.byKey(const Key('save-note-button')));
      await tester.pumpAndSettle();

      expect(find.text('Rangkuman Metopen'), findsOneWidget);
      expect(repository.notes, hasLength(1));
      expect(repository.notes.single.body, 'Menyusun rancangan metode penelitian.');
    });

    testWidgets('menampilkan pesan jika repository gagal menyimpan', (
      tester,
    ) async {
      final repository = FakeNoteRepository(
        addError: 'Penyimpanan catatan gagal',
      );

      await tester.pumpWidget(createTestApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('note-title-field')),
        'Catatan gagal simpan',
      );
      await tester.tap(find.byKey(const Key('save-note-button')));
      await tester.pumpAndSettle();

      expect(find.text('Penyimpanan catatan gagal'), findsOneWidget);
      expect(repository.notes, isEmpty);
    });

    testWidgets('memfilter daftar berdasarkan judul', (tester) async {
      final repository = FakeNoteRepository(
        initialNotes: [
          createNote(id: 1, title: 'Belajar Flutter'),
          createNote(id: 2, title: 'Metodologi Penelitian'),
        ],
      );

      await tester.pumpWidget(createTestApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('notes-search-field')),
        'METODOLOGI',
      );
      await tester.pumpAndSettle();

      expect(find.text('Metodologi Penelitian'), findsOneWidget);
      expect(find.text('Belajar Flutter'), findsNothing);
    });

    testWidgets('menampilkan error dan dapat mencoba memuat ulang', (
      tester,
    ) async {
      final repository = FakeNoteRepository(
        fetchError: 'Database sedang tidak tersedia',
      );

      await tester.pumpWidget(createTestApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Database sedang tidak tersedia'),
        findsOneWidget,
      );
      expect(find.text('Coba Lagi'), findsOneWidget);

      repository.fetchError = null;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada catatan.'), findsOneWidget);
    });
  });
}
