import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/todo_provider.dart';
import 'widgets/todo_item.dart';
import 'widgets/add_todo_dialog.dart';
import 'widgets/todo_filter_bar.dart';

/// Main screen of the Todo app.
///
/// Displays the list of todos with a filter bar at the top and a
/// floating action button to add new tasks.
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(filteredTodosProvider);
    final remaining = ref.watch(remainingCountProvider);
    final completed = ref.watch(completedCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          if (completed > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(todoListProvider.notifier).clearCompleted();
              },
              icon: const Icon(Icons.cleaning_services_outlined, size: 18),
              label: const Text('Clear done'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          const TodoFilterBar(),
          // Remaining count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '$remaining item${remaining == 1 ? '' : 's'} left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Todo list
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return _EmptyState();
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return TodoItem(todo: todos[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(todoListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }
}

/// Shown when the filtered list is empty.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks here',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
