import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca full todo list untuk dihitung
    final todos = ref.watch(todoListProvider);
    final total = todos.length;
    final completed = todos.where((t) => t.done).length;
    final active = total - completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Tugas: $total', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Selesai: $completed', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green)),
            const SizedBox(height: 8),
            Text('Belum Selesai: $active', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}