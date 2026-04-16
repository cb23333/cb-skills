import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';

/// The main home screen displaying the list of todos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> _todos = [];
  TodoFilter _currentFilter = TodoFilter.all;

  /// Get filtered todos based on the current filter.
  List<Todo> get _filteredTodos {
    switch (_currentFilter) {
      case TodoFilter.all:
        return _todos;
      case TodoFilter.active:
        return _todos.where((todo) => !todo.isCompleted).toList();
      case TodoFilter.completed:
        return _todos.where((todo) => todo.isCompleted).toList();
    }
  }

  /// Get count of remaining active tasks.
  int get _activeCount => _todos.where((todo) => !todo.isCompleted).length;

  /// Add a new todo task.
  void _addTodo(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _todos.insert(
        0,
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
        ),
      );
    });
  }

  /// Toggle the completion status of a todo.
  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((todo) => todo.id == id);
      todo.toggleComplete();
    });
  }

  /// Delete a todo by its id.
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Show the dialog to add a new todo.
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(onAdd: _addTodo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _filteredTodos;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'My Todos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // Filter chips row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '$_activeCount task${_activeCount != 1 ? 's' : ''} left',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                _buildFilterChip(TodoFilter.all, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(TodoFilter.active, 'Active'),
                const SizedBox(width: 8),
                _buildFilterChip(TodoFilter.completed, 'Done'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Todo list
          Expanded(
            child: filteredTodos.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return TodoItem(
                        todo: todo,
                        onToggle: () => _toggleTodo(todo.id),
                        onDelete: () => _deleteTodo(todo.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  /// Build a filter chip widget.
  Widget _buildFilterChip(TodoFilter filter, String label) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
    );
  }

  /// Build the empty state placeholder.
  Widget _buildEmptyState(ThemeData theme) {
    String message;
    switch (_currentFilter) {
      case TodoFilter.all:
        message = 'No tasks yet.\nTap "+" to add your first task!';
        break;
      case TodoFilter.active:
        message = 'No active tasks.\nAll tasks are completed!';
        break;
      case TodoFilter.completed:
        message = 'No completed tasks yet.\nKeep working on it!';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist,
              size: 80,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enum for filtering todos.
enum TodoFilter { all, active, completed }
