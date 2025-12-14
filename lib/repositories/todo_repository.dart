import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';
import '../services/connectivity_service.dart';
import '../services/todo_api_service.dart';

class TodoRepository {
  static const String _todosKey = 'todos_list_v1';

  final TodoApiService apiService;
  final ConnectivityService connectivity;

  TodoRepository({
    required this.apiService,
    required this.connectivity,
  });

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<TodoItem>> getTodos() async {
    final isOnline = connectivity.isConnected;

    if (isOnline) {
      try {
        final todos = await apiService.fetchTodos();
        await saveTasks(todos);
        return todos;
      } catch (_) {
        return loadTasks();
      }
    }

    return loadTasks();
  }

  Future<List<TodoItem>> loadTasks() async {
    final p = await _prefs;
    final raw = p.getString(_todosKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<TodoItem> tasks) async {
    final p = await _prefs;
    final raw = json.encode(tasks.map((t) => t.toJson()).toList());
    await p.setString(_todosKey, raw);
  }
}
