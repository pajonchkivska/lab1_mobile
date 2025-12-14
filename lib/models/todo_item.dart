// lib/models/todo_item.dart

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueTime;
  final bool isAllDay;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueTime,
    this.isAllDay = false,
  });

  /// Використовується для локального кешу (SharedPreferences)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'dueTime': dueTime?.toIso8601String(),
        'isAllDay': isAllDay,
      };

  /// Використовується для API (mockapi / backend)
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDueTime;

    final rawDueTime =
        json['dueTime'] ?? json['due_date'] ?? json['dateTime'];

    if (rawDueTime is String && rawDueTime.isNotEmpty) {
      parsedDueTime = DateTime.tryParse(rawDueTime);
    }

    return TodoItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['text'] ?? 'Untitled task').toString(),
      isCompleted:
          (json['isCompleted'] ?? json['completed'] ?? false) == true,
      isAllDay: (json['isAllDay'] ?? false) == true,
      dueTime: parsedDueTime,
    );
  }

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueTime,
    bool? isAllDay,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueTime: dueTime ?? this.dueTime,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}
