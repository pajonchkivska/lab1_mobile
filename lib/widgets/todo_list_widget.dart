import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoListWidget extends StatelessWidget {
  final List<TodoItem> items;
  final String Function(DateTime) formatTime;
  final void Function(int) onToggle;
  final void Function(int) onDelete;

  const TodoListWidget({
    required this.items,
    required this.formatTime,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('No tasks for this day'));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];

        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(index),
          child: Card(
            child: ListTile(
              leading: Checkbox(
                value: item.isCompleted,
                onChanged: (_) => onToggle(index),
              ),
              title: Text(item.title),
              subtitle: item.dueTime != null
                  ? Text(item.isAllDay ? 'All Day' : formatTime(item.dueTime!))
                  : const Text('No Time'),
            ),
          ),
        );
      },
    );
  }
}
