import 'package:moong_flutter/database/user_dao.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/repositories/interfaces/user_repository.dart';

/// SQLite implementation of UserRepository
/// Wraps UserDao to conform to repository interface
class UserRepositorySQLite implements UserRepository {
  final UserDao _dao = UserDao();

  @override
  Future<User?> getUser(String id) => _dao.getUser(id);

  @override
  Future<User?> getCurrentUser() => _dao.getCurrentUser();

  @override
  Future<void> createUser(User user) async {
    await _dao.insertUser(user);
  }

  @override
  Future<void> updateUser(User user) async {
    await _dao.updateUser(user);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _dao.deleteUser(id);
  }

  @override
  Future<bool> userExists(String id) => _dao.userExists(id);
}
