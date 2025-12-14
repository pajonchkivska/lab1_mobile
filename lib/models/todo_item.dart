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


  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'dueTime': dueTime?.toIso8601String(), 
        'isAllDay': isAllDay,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTime;
    if (json['dueTime'] != null) {
      parsedTime = DateTime.tryParse(json['dueTime'] as String); 
    }
    
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      dueTime: parsedTime,
      isAllDay: json['isAllDay'] as bool? ?? false, 
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
      dueTime: dueTime, 
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}