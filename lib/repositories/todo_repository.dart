// lib/repositories/todo_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoRepository {
  static const String _todosKey = 'todos_list_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // Завантаження всіх завдань
  Future<List<TodoItem>> loadTasks() async {
    final p = await _prefs;
    final raw = p.getString(_todosKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    
    final List<dynamic> decodedList = json.decode(raw) as List<dynamic>;
    return decodedList.map((json) => TodoItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Збереження всіх завдань
  Future<void> saveTasks(List<TodoItem> tasks) async {
    final p = await _prefs;
    final encodedList = tasks.map((item) => item.toJson()).toList();
    final raw = json.encode(encodedList);
    await p.setString(_todosKey, raw);
  }
}