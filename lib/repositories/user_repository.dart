import '../models/user.dart';

abstract class UserRepository {
  Future<void> saveUser(User user);
  Future<User?> getUserByEmail(String email);
  Future<void> updateUser(String oldEmail, User newUser);
  Future<void> deleteUser(String email);
}
