// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  AuthResult({required this.success, this.message, this.user});
}

class UserExistsError implements Exception {
  final String message;
  UserExistsError(this.message);
}

class AuthService {
  final UserRepository repository;

  final String _sessionKey = 'is_logged_in';
  final String _currentUserEmailKey = 'current_user_email';

  AuthService({required this.repository});


  Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setString(_currentUserEmailKey, user.email);
  }

 
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
    await prefs.remove(_currentUserEmailKey);
  }


  Future<User?> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_sessionKey) ?? false;
    
    if (isLoggedIn) {
      final email = prefs.getString(_currentUserEmailKey);
      if (email != null) {
        return await repository.getUserByEmail(email); 
      }
    }
    return null;
  }
  

  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name cannot be empty.';
    }
    if (RegExp(r'\d').hasMatch(name)) {
      return 'Name cannot contain numbers.';
    }
    return null;
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty.';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }


  Future<AuthResult> register({required String name, required String email, required String password}) async {
    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (nameError != null || emailError != null || passwordError != null) {
      return AuthResult(success: false, message: nameError ?? emailError ?? passwordError);
    }

    if (await repository.getUserByEmail(email) != null) {
      return AuthResult(success: false, message: 'User with this email already exists.');
    }

    final newUser = User(
      name: name,
      email: email,
      password: password,
    );

    try {
      await repository.saveUser(newUser);
      await saveSession(newUser); 
      return AuthResult(success: true, user: newUser);
    } catch (e) {
      return AuthResult(success: false, message: 'Registration failed.');
    }
  }


  Future<AuthResult> login({required String email, required String password}) async {
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      return AuthResult(success: false, message: emailError ?? passwordError);
    }

    final user = await repository.getUserByEmail(email);

    if (user == null || user.password != password) {
      return AuthResult(success: false, message: 'Invalid email or password.');
    }
    
    await saveSession(user); 
    
    return AuthResult(success: true, user: user);
  }


  Future<AuthResult> updateProfile({required String oldEmail, required String newName, required String newEmail, required String newPassword}) async {
    final nameError = validateName(newName);
    final emailError = validateEmail(newEmail);
    final passwordError = validatePassword(newPassword);

    if (nameError != null || emailError != null || passwordError != null) {
      return AuthResult(success: false, message: nameError ?? emailError ?? passwordError);
    }

    final userWithNewEmail = await repository.getUserByEmail(newEmail);
    if (userWithNewEmail != null && userWithNewEmail.email != oldEmail) {
      return AuthResult(success: false, message: 'This email is already taken by another account.');
    }

    final updatedUser = User(
      name: newName,
      email: newEmail,
      password: newPassword,
    );

    try {
      await repository.updateUser(oldEmail, updatedUser);
      if (oldEmail != newEmail) {
        await saveSession(updatedUser); 
      }
      return AuthResult(success: true, user: updatedUser, message: 'Profile updated successfully.');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to update profile.');
    }
  }


  Future<AuthResult> deleteUser(String email) async {
    try {
      await repository.deleteUser(email);
      await clearSession(); 
      return AuthResult(success: true, message: 'Account deleted successfully.');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to delete account.');
    }
  }
}