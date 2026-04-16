import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/todo_model.dart';
import '../data/todo_repository.dart';

/// Enum for filtering the todo list.
enum TodoFilter { all, active, completed }

/// Provider that holds the current filter selection.
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

/// Async notifier that manages the full todo list with persistence.
class TodoListNotifier extends AsyncNotifier<List<TodoModel>> {
  @override
  Future<List<TodoModel>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.getAllTodos();
  }

  /// Persist the current list to local storage.
  Future<void> _persist() async {
    final repository = ref.read(todoRepositoryProvider);
    final todos = state.valueOrNull ?? [];
    await repository.saveAllTodos(todos);
  }

  /// Add a new todo with the given [title].
  Future<void> addTodo(String title) async {
    final todo = TodoModel(
      id: const Uuid().v4(),
      title: title.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    final current = state.valueOrNull ?? [];
    state = AsyncData([todo, ...current]);
    await _persist();
  }

  /// Toggle the completed status of a todo by [id].
  Future<void> toggleTodo(String id) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current
          .map((t) => t.id == id ? t.copyWith(isCompleted: !t.isCompleted) : t)
          .toList(),
    );
    await _persist();
  }

  /// Delete a todo by [id].
  Future<void> deleteTodo(String id) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
    await _persist();
  }

  /// Edit the title of an existing todo.
  Future<void> editTodo(String id, String newTitle) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current
          .map((t) =>
              t.id == id ? t.copyWith(title: newTitle.trim()) : t)
          .toList(),
    );
    await _persist();
  }

  /// Clear all completed todos.
  Future<void> clearCompleted() async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((t) => !t.isCompleted).toList());
    await _persist();
  }
}

/// Provider for the todo list notifier.
final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<TodoModel>>(
  TodoListNotifier.new,
);

/// Derived provider: filtered todo list based on the selected filter.
final filteredTodosProvider = Provider<AsyncValue<List<TodoModel>>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todosAsync = ref.watch(todoListProvider);

  return todosAsync.whenData((todos) {
    switch (filter) {
      case TodoFilter.all:
        return todos;
      case TodoFilter.active:
        return todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();
    }
  });
});

/// Derived provider: count of remaining (uncompleted) todos.
final remainingCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoListProvider).valueOrNull ?? [];
  return todos.where((t) => !t.isCompleted).length;
});

/// Derived provider: count of completed todos.
final completedCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoListProvider).valueOrNull ?? [];
  return todos.where((t) => t.isCompleted).length;
});
