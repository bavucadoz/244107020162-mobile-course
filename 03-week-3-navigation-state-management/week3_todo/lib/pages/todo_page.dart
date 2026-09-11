import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca list yang sudah difilter
    final filteredTodos = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          // Menu popup untuk mengubah filter
          PopupMenuButton<TodoFilter>(
            onSelected: (filter) =>
                ref.read(todoFilterProvider.notifier).state = filter,
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('Semua')),
              PopupMenuItem(value: TodoFilter.active, child: Text('Belum Selesai')),
              PopupMenuItem(value: TodoFilter.completed, child: Text('Selesai')),
            ],
          ),
        ],
      ),
      body: filteredTodos.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                
                return TodoTile(
                  title: todo.title,
                  isDone: todo.done,
                  onToggle: (_) {
                    // Cari index asli dari seluruh list agar tidak salah ubah saat difilter
                    final originalIndex = ref.read(todoListProvider).indexOf(todo);
                    if (originalIndex != -1) {
                      ref.read(todoListProvider.notifier).toggle(originalIndex);
                    }
                  },
                  onDelete: () {
                    // Cari index asli dari seluruh list agar tidak salah hapus saat difilter
                    final originalIndex = ref.read(todoListProvider).indexOf(todo);
                    if (originalIndex != -1) {
                      ref.read(todoListProvider.notifier).remove(originalIndex);
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              controller.clear();
              
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}