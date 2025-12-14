import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_repository.dart';

class LocalUserRepository implements UserRepository {
  static const String usersKey = 'users_map_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Map<String, String>> _readMap() async {
    final p = await _prefs;
    final raw = p.getString(usersKey);
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _writeMap(Map<String, String> map) async {
    final p = await _prefs;
    final encoded = json.encode(map);
    await p.setString(usersKey, encoded);
  }

  @override
  Future<void> saveUser(User user) async {
    final map = await _readMap();
    map[user.email] = json.encode(user.toJson());
    await _writeMap(map);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final map = await _readMap();
    final raw = map[email];
    if (raw == null) return null;
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    return User.fromJson(jsonMap);
  }

  @override
  Future<void> updateUser(String oldEmail, User newUser) async {
    final map = await _readMap();
    if (oldEmail != newUser.email) {
      // remove old key
      map.remove(oldEmail);
    }
    map[newUser.email] = json.encode(newUser.toJson());
    await _writeMap(map);
  }

  @override
  Future<void> deleteUser(String email) async {
    final map = await _readMap();
    map.remove(email);
    await _writeMap(map);
  }
}
