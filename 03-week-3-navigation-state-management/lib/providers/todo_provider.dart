import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  void add(String title) {
    state = [...state, Todo(title: title)];
  }

  void toggle(int index) {
    if (index < 0 || index >= state.length) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(done: !state[i].done) else state[i]
    ];
  }

  void remove(int index) {
    if (index < 0 || index >= state.length) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }
}

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

enum TodoFilter { all, active, completed }

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((t) => !t.done).toList();
    case TodoFilter.completed:
      return todos.where((t) => t.done).toList();
    case TodoFilter.all:
      return todos;
  }
});