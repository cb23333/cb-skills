import 'package:flutter/material.dart';
import '../models/todo.dart';

/// A widget that displays a single todo item with toggle and delete actions.
class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            _formatDate(todo.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: theme.colorScheme.error.withOpacity(0.7),
            onPressed: onDelete,
            tooltip: 'Delete task',
          ),
        ),
      ),
    );
  }

  /// Format the date to a readable string.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}
