import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert a new user
  Future<int> insertUser(User user) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      debugPrint('Error inserting user: $e');
      rethrow;
    }
  }

  // Update an existing user
  Future<int> updateUser(User user) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return result;
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // Get a user by ID
  Future<User?> getUser(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  // Get the most recently created user (for login purposes)
  Future<User?> getCurrentUser() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'users',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      rethrow;
    }
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('users', orderBy: 'created_at DESC');
      return maps.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      rethrow;
    }
  }

  // Delete a user
  Future<int> deleteUser(String id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  // Check if user exists
  Future<bool> userExists(String id) async {
    try {
      final user = await getUser(id);
      return user != null;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
      rethrow;
    }
  }
}
