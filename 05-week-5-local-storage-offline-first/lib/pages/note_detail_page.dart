import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../providers.dart';

final noteDetailProvider =
    FutureProvider.autoDispose.family<Note?, int>((ref, id) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.fetchNoteById(id);
});

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Catatan #$noteId'),
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(
              child: Text('Catatan tidak ditemukan.'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (note.dirty)
                      Chip(
                        label: const Text('belum tersinkron'),
                        backgroundColor: Colors.orange.shade100,
                        labelStyle: TextStyle(color: Colors.orange.shade900),
                      )
                    else
                      const Chip(
                        label: Text('Tersinkron'),
                        backgroundColor: Colors.greenAccent,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Terakhir diperbarui: ${note.updatedAt.toLocal()}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Divider(height: 32),
                Text(
                  note.body.isNotEmpty ? note.body : '(Tanpa isi catatan)',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}