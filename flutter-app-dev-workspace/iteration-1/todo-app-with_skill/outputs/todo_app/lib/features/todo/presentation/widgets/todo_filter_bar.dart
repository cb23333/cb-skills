import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/todo_provider.dart';

/// A horizontal row of filter chips (All / Active / Completed).
class TodoFilterBar extends ConsumerWidget {
  const TodoFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(todoFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TodoFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(_labelFor(filter)),
              onSelected: (_) {
                ref.read(todoFilterProvider.notifier).state = filter;
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.completed:
        return 'Completed';
    }
  }
}
