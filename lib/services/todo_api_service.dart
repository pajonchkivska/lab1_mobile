import 'dart:convert';
import '../models/todo_item.dart';
import 'api_client.dart';

class TodoApiService {
  final ApiClient client;
  TodoApiService(this.client);

  Future<List<TodoItem>> fetchTodos() async {
    final res = await client.get('/todos');
    if (res.statusCode != 200) {
      throw Exception('Failed to load todos: ${res.statusCode}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => TodoItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
