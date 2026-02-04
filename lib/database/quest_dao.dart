import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quest.dart';
import '../services/database_helper.dart';

class QuestDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert a new quest
  Future<int> insertQuest(Quest quest) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'quests',
        quest.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      debugPrint('Error inserting quest: $e');
      rethrow;
    }
  }

  // Update an existing quest
  Future<int> updateQuest(Quest quest) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'quests',
        quest.toMap(),
        where: 'id = ?',
        whereArgs: [quest.id],
      );
      return result;
    } catch (e) {
      debugPrint('Error updating quest: $e');
      rethrow;
    }
  }

  // Get a quest by ID
  Future<Quest?> getQuest(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'quests',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return Quest.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting quest: $e');
      rethrow;
    }
  }

  // Get all quests for a specific user
  Future<List<Quest>> getQuestsByUserId(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'quests',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Quest.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting quests by user ID: $e');
      rethrow;
    }
  }

  // Get active (not completed) quests for a user
  Future<List<Quest>> getActiveQuests(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'quests',
        where: 'user_id = ? AND completed = 0',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Quest.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting active quests: $e');
      rethrow;
    }
  }

  // Get completed quests for a user
  Future<List<Quest>> getCompletedQuests(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'quests',
        where: 'user_id = ? AND completed = 1',
        whereArgs: [userId],
        orderBy: 'completed_at DESC',
      );

      return maps.map((map) => Quest.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting completed quests: $e');
      rethrow;
    }
  }

  // Get today's quests for a user
  Future<List<Quest>> getTodayQuests(String userId) async {
    try {
      final db = await _dbHelper.database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).millisecondsSinceEpoch;

      final maps = await db.query(
        'quests',
        where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
        whereArgs: [userId, startOfDay, endOfDay],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => Quest.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting today quests: $e');
      rethrow;
    }
  }

  // Update quest progress
  Future<int> updateQuestProgress(String questId, int progress) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'quests',
        {'progress': progress},
        where: 'id = ?',
        whereArgs: [questId],
      );
      return result;
    } catch (e) {
      debugPrint('Error updating quest progress: $e');
      rethrow;
    }
  }

  // Mark quest as completed
  Future<int> completeQuest(String questId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'quests',
        {
          'completed': 1,
          'completed_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [questId],
      );
      return result;
    } catch (e) {
      debugPrint('Error completing quest: $e');
      rethrow;
    }
  }

  // Delete a quest
  Future<int> deleteQuest(String id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'quests',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting quest: $e');
      rethrow;
    }
  }

  // Delete all quests for a user (usually not needed due to CASCADE)
  Future<int> deleteAllQuestsForUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'quests',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting all quests for user: $e');
      rethrow;
    }
  }

  // Check if quest exists
  Future<bool> questExists(String id) async {
    try {
      final quest = await getQuest(id);
      return quest != null;
    } catch (e) {
      debugPrint('Error checking if quest exists: $e');
      rethrow;
    }
  }

  // Get quest completion rate for a user
  Future<double> getCompletionRate(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed
        FROM quests
        WHERE user_id = ?
      ''', [userId]);

      if (result.isEmpty) return 0.0;

      final total = result.first['total'] as int;
      final completed = result.first['completed'] as int;

      if (total == 0) return 0.0;
      return completed / total;
    } catch (e) {
      debugPrint('Error getting completion rate: $e');
      rethrow;
    }
  }

  // Batch insert multiple quests
  Future<void> insertQuests(List<Quest> quests) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var quest in quests) {
        batch.insert(
          'quests',
          quest.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error batch inserting quests: $e');
      rethrow;
    }
  }
}
