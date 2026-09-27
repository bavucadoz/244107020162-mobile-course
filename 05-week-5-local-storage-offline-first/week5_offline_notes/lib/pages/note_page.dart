import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/note_repository.dart';
import '../data/local/note.dart';
import 'settings_pages.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

// Fetch daftar catatan dari database SQLite
final notesProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

// Hitung jumlah catatan dengan status dirty (belum tersinkron)
final dirtyCountProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tambah Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await ref.read(noteRepositoryProvider).addNote(
                      title: titleController.text,
                      body: bodyController.text,
                    );
                ref.invalidate(notesProvider);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          // Tombol Sync dengan indikator Badge catatan dirty
          IconButton(
            icon: Badge(
              label: Text('$dirtyCount'),
              isLabelVisible: dirtyCount > 0,
              child: const Icon(Icons.sync),
            ),
            onPressed: () async {
              final repo = ref.read(noteRepositoryProvider);
              await Future.delayed(const Duration(seconds: 1)); // Simulasi delay server
              await repo.markAllSynced();
              ref.invalidate(notesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  '${note.body}\nStatus: ${note.dirty ? "Dirty (Belum Sync)" : "Synced"}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (note.id != null) {
                      await ref.read(noteRepositoryProvider).deleteNote(note.id!);
                      ref.invalidate(notesProvider);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}