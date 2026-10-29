import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/presentation/widgets/notes_empty_state.dart';

void main() {
  testWidgets('menampilkan empty state untuk hasil pencarian kosong', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NotesEmptyState(query: 'zzz')),
      ),
    );

    expect(find.text('Tidak ada catatan untuk "zzz".'), findsOneWidget);
  });

  testWidgets('menampilkan pesan awal saat belum ada catatan', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NotesEmptyState(query: '')),
      ),
    );

    expect(find.text('Belum ada catatan.'), findsOneWidget);
  });
}
