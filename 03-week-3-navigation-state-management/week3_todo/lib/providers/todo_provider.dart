import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- MODEL ---
class Todo {
  final String title;
  final bool done;

  Todo({required this.title, this.done = false});

  Todo copyWith({String? title, bool? done}) {
    return Todo(
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }
}

// --- NOTIFIER ---
class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  void add(String title) {
    state = [...state, Todo(title: title)];
  }

  void toggle(int index) {
    // 1. Cek pengaman agar tidak error jika index tidak valid (-1)
    if (index < 0 || index >= state.length) return;

    // 2. Gunakan pendekatan for loop yang jauh lebih aman dari .sublist
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) 
          state[i].copyWith(done: !state[i].done) 
        else 
          state[i]
    ];
  }

  void remove(int index) {
    // 1. Cek pengaman 
    if (index < 0 || index >= state.length) return;

    // 2. Buat list baru yang HANYA berisi item selain index yang dihapus
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }
}

// --- PROVIDERS ---
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

// Enum untuk jenis filter
enum TodoFilter { all, active, completed }

// Provider untuk menyimpan state filter terpilih (default: semua)
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// Provider turunan yang membaca todoListProvider dan memfilternya
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((todo) => !todo.done).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.done).toList();
    case TodoFilter.all:
      return todos;
  }
});