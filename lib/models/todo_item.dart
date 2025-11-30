// lib/models/todo_item.dart

class TodoItem {
  final String id;
  final String title;
  final DateTime? dueTime; // Optional time (для "Весь день" буде null)
  final bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.dueTime,
    this.isCompleted = false,
  });

  // Метод для створення копії завдання зі зміненими полями
  TodoItem copyWith({
    String? title,
    DateTime? dueTime,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      dueTime: dueTime, // Передача dueTime прямо (бо він може бути null)
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Перетворення в JSON для збереження
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueTime': dueTime?.toIso8601String(), // Зберігаємо як рядок
        'isCompleted': isCompleted,
      };

  // Створення з JSON при завантаженні
  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        dueTime: json['dueTime'] != null ? DateTime.parse(json['dueTime'] as String) : null,
        isCompleted: json['isCompleted'] as bool,
      );
}