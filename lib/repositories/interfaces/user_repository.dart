import 'package:moong_flutter/models/user.dart';

/// Repository interface for User data operations
abstract class UserRepository {
  /// Get user by ID
  Future<User?> getUser(String id);

  /// Get currently logged-in user
  Future<User?> getCurrentUser();

  /// Create a new user
  Future<void> createUser(User user);

  /// Update existing user
  Future<void> updateUser(User user);

  /// Delete user by ID
  Future<void> deleteUser(String id);

  /// Check if user exists by ID
  Future<bool> userExists(String id);
}
