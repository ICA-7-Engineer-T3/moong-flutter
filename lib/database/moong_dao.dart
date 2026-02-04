import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/moong.dart';
import '../services/database_helper.dart';

class MoongDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert a new moong
  Future<int> insertMoong(Moong moong) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'moongs',
        moong.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      debugPrint('Error inserting moong: $e');
      rethrow;
    }
  }

  // Update an existing moong
  Future<int> updateMoong(Moong moong) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'moongs',
        moong.toMap(),
        where: 'id = ?',
        whereArgs: [moong.id],
      );
      return result;
    } catch (e) {
      debugPrint('Error updating moong: $e');
      rethrow;
    }
  }

  // Get a moong by ID
  Future<Moong?> getMoong(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'moongs',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return Moong.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting moong: $e');
      rethrow;
    }
  }

  // Get all moongs for a specific user
  Future<List<Moong>> getMoongsByUserId(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'moongs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Moong.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting moongs by user ID: $e');
      rethrow;
    }
  }

  // Get active moongs for a specific user
  Future<List<Moong>> getActiveMoongs(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'moongs',
        where: 'user_id = ? AND is_active = 1',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Moong.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting active moongs: $e');
      rethrow;
    }
  }

  // Get the first active moong for a user
  Future<Moong?> getActiveMoong(String userId) async {
    try {
      final moongs = await getActiveMoongs(userId);
      return moongs.isNotEmpty ? moongs.first : null;
    } catch (e) {
      debugPrint('Error getting active moong: $e');
      rethrow;
    }
  }

  // Get graduated moongs for a specific user
  Future<List<Moong>> getGraduatedMoongs(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'moongs',
        where: 'user_id = ? AND is_active = 0 AND graduated_at IS NOT NULL',
        whereArgs: [userId],
        orderBy: 'graduated_at DESC',
      );

      return maps.map((map) => Moong.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting graduated moongs: $e');
      rethrow;
    }
  }

  // Delete a moong
  Future<int> deleteMoong(String id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'moongs',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting moong: $e');
      rethrow;
    }
  }

  // Delete all moongs for a user (usually not needed due to CASCADE)
  Future<int> deleteAllMoongsForUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'moongs',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting all moongs for user: $e');
      rethrow;
    }
  }

  // Check if moong exists
  Future<bool> moongExists(String id) async {
    try {
      final moong = await getMoong(id);
      return moong != null;
    } catch (e) {
      debugPrint('Error checking if moong exists: $e');
      rethrow;
    }
  }

  // Batch insert multiple moongs
  Future<void> insertMoongs(List<Moong> moongs) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var moong in moongs) {
        batch.insert(
          'moongs',
          moong.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error batch inserting moongs: $e');
      rethrow;
    }
  }
}
