import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/todo_model.dart';
import '../../domain/todo_provider.dart';

/// A single todo item displayed as a dismissible card.
///
/// Swipe left to delete. Tap the checkbox to toggle completion.
/// Long-press or tap the edit icon to edit the title.
class TodoItem extends ConsumerStatefulWidget {
  final TodoModel todo;

  const TodoItem({super.key, required this.todo});

  @override
  ConsumerState<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends ConsumerState<TodoItem> {
  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(todoListProvider.notifier).deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${todo.title}"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Re-add the todo back
                ref.read(todoListProvider.notifier).addTodo(todo.title);
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: colorScheme.onErrorContainer,
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) {
            ref.read(todoListProvider.notifier).toggleTodo(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          _formatDate(todo.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => _showEditDialog(context, todo),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  void _showEditDialog(BuildContext context, TodoModel todo) {
    final controller = TextEditingController(text: todo.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Task title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submitEdit(context, todo.id, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _submitEdit(context, todo.id, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _submitEdit(BuildContext context, String id, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    ref.read(todoListProvider.notifier).editTodo(id, newTitle);
    Navigator.of(context).pop();
  }
}
