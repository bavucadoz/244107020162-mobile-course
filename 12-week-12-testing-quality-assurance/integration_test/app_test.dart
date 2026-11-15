import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';
import 'package:campus_notify/router.dart';

import '../test/support/fake_note_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'pengguna dapat menambahkan catatan lalu membuka halaman detail',
    (tester) async {
      // Arrange: gunakan router dan halaman aplikasi asli, dengan fake
      // repository agar test tidak bergantung pada database perangkat.
      final repository = FakeNoteRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Act: tambahkan catatan melalui UI.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('note-title-field')),
        'Catatan Integrasi',
      );
      await tester.enterText(
        find.byKey(const Key('note-body-field')),
        'Alur daftar menuju detail berjalan.',
      );
      await tester.tap(find.byKey(const Key('save-note-button')));
      await tester.pumpAndSettle();

      // Assert: catatan tampil di daftar.
      expect(find.text('Catatan Integrasi'), findsOneWidget);
      expect(repository.notes, hasLength(1));

      // Act: buka detail catatan melalui navigasi aplikasi.
      await tester.tap(find.text('Catatan Integrasi'));
      await tester.pumpAndSettle();

      // Assert: halaman detail menampilkan isi catatan yang sama.
      expect(find.text('Detail Catatan #1'), findsOneWidget);
      expect(
        find.text('Alur daftar menuju detail berjalan.'),
        findsOneWidget,
      );
    },
  );
}
