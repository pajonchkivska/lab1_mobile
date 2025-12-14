import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient client;
  AuthApiService(this.client);

  Future<User> login(String email, String password) async {
    final res = await client.post('/login', {'email': email, 'password': password});
    if (res.statusCode != 200) throw Exception('Login failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return User.fromJson(data); // очікуємо token всередині, якщо є
  }

  Future<User> register(String name, String email, String password) async {
    final res = await client.post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (res.statusCode != 200) throw Exception('Register failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }
}
