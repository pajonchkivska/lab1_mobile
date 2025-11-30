// lib/services/auth_service.dart

import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  const AuthResult(this.success, this.message, [this.user]);
}

class AuthService {
  final UserRepository repository;

  AuthService({required this.repository});

  // Проста валідація (тексти перекладено)
  String? validateName(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    final hasDigit = RegExp(r'\d').hasMatch(name);
    if (hasDigit) return 'Name must not contain digits';
    return null;
  }

  String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required';
    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      return 'Email is invalid';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final vName = validateName(name);
    final vEmail = validateEmail(email);
    final vPass = validatePassword(password);
    if (vName != null) return AuthResult(false, vName);
    if (vEmail != null) return AuthResult(false, vEmail);
    if (vPass != null) return AuthResult(false, vPass);

    final existing = await repository.getUserByEmail(email);
    if (existing != null) {
      return const AuthResult(false, 'User with this email already exists');
    }

    final user = User(name: name.trim(), email: email.trim(), password: password);
    await repository.saveUser(user);
    return AuthResult(true, 'Registered', user);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final vEmail = validateEmail(email);
    if (vEmail != null) return AuthResult(false, vEmail);
    final user = await repository.getUserByEmail(email.trim());
    if (user == null) return const AuthResult(false, 'No user with that email');
    if (user.password != password) return const AuthResult(false, 'Wrong password');
    return AuthResult(true, 'Logged in', user);
  }

  Future<AuthResult> updateProfile({
    required String oldEmail,
    required String name,
    required String email,
    required String password,
  }) async {
    final vName = validateName(name);
    final vEmail = validateEmail(email);
    final vPass = validatePassword(password);

    if (vName != null) return AuthResult(false, vName);
    if (vEmail != null) return AuthResult(false, vEmail);
    if (vPass != null) return AuthResult(false, vPass);

    final updated = User(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );

    try {
      await repository.updateUser(oldEmail, updated);
      return AuthResult(true, 'Profile updated', updated);
    } on StateError catch (e) {
      // Текст помилки від репозиторію вже англійською
      return AuthResult(false, e.message); 
    } catch (e) {
      return const AuthResult(false, 'Failed to update profile.');
    }
  }

  Future<void> deleteUser(String email) async {
    await repository.deleteUser(email);
  }
}