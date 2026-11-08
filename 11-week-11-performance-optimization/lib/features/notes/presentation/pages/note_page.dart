// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/search_notes.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';
import '../widgets/notes_empty_state.dart';

final dirtyCountProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(notesProvider);
  final repo = ref.watch(noteRepositoryProvider);

  final result = await repo.countDirty();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.count;
});

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String _query = '';

  Future<void> _showAddDialog() async {
    final draft = await showDialog<_NoteDraft>(
      context: context,
      builder: (_) => const _AddNoteDialog(),
    );

    if (!mounted || draft == null) return;

    final result = await ref
        .read(noteRepositoryProvider)
        .addNote(title: draft.title, body: draft.body);

    if (!mounted) return;
    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure!.message)),
      );
      return;
    }

    ref.invalidate(notesProvider);
  }

  Future<void> _refreshNotes() async {
    try {
      await ref.refresh(notesProvider.future);
    } catch (_) {
      // The FutureProvider exposes the error to notesAsync and ErrorView.
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            tooltip: 'CampusMate AI',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => context.push('/ai-chat'),
          ),
          IconButton(
            icon: Badge(
              label: Text('$dirtyCount'),
              isLabelVisible: dirtyCount > 0,
              child: const Icon(Icons.sync),
            ),
            onPressed: () async {
              final repo = ref.read(noteRepositoryProvider);
              await Future.delayed(const Duration(seconds: 1));
              await repo.markAllSynced();
              ref.invalidate(notesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(notesProvider),
        ),
        data: (notes) {
          final filteredNotes = filterNotesByTitle(notes, _query);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  key: const Key('notes-search-field'),
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    labelText: 'Cari judul catatan',
                    hintText: 'Masukkan judul notes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            key: const Key('clear-search-button'),
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _query = ''),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshNotes,
                  child: filteredNotes.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 260,
                              child: NotesEmptyState(query: _query),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return NoteTile(
                              note: note,
                              onTap: () {
                                if (note.id != null) {
                                  context.push('/note/${note.id}');
                                }
                              },
                              onDelete: () async {
                                if (note.id != null) {
                                  await ref
                                      .read(noteRepositoryProvider)
                                      .deleteNote(note.id!);
                                  ref.invalidate(notesProvider);
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteDraft {
  const _NoteDraft({required this.title, required this.body});

  final String title;
  final String body;
}

class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Judul catatan wajib diisi.');
      return;
    }

    Navigator.of(context).pop(
      _NoteDraft(title: title, body: _bodyController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Judul',
              errorText: _titleError,
            ),
          ),
          TextField(
            controller: _bodyController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Isi'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
