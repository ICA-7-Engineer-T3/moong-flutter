import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';
import '../services/database_helper.dart';

class ChatMessageDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert a new chat message
  Future<int> insertMessage(ChatMessage message) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'chat_messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      debugPrint('Error inserting chat message: $e');
      rethrow;
    }
  }

  // Get a message by ID
  Future<ChatMessage?> getMessage(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'chat_messages',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ChatMessage.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting chat message: $e');
      rethrow;
    }
  }

  // Get all messages for a specific moong
  Future<List<ChatMessage>> getMessagesByMoong(
    String moongId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'chat_messages',
        where: 'moong_id = ?',
        whereArgs: [moongId],
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      return maps.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting messages by moong: $e');
      rethrow;
    }
  }

  // Get all messages for a user
  Future<List<ChatMessage>> getMessagesByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'chat_messages',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting messages by user: $e');
      rethrow;
    }
  }

  // Get recent messages for a moong
  Future<List<ChatMessage>> getRecentMessages(String moongId, int limit) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'chat_messages',
        where: 'moong_id = ?',
        whereArgs: [moongId],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      // Return in chronological order (oldest first)
      return maps.reversed.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting recent messages: $e');
      rethrow;
    }
  }

  // Get messages within a date range
  Future<List<ChatMessage>> getMessagesInRange(
    String moongId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final startTimestamp = startDate.millisecondsSinceEpoch;
      final endTimestamp = endDate.millisecondsSinceEpoch;

      final maps = await db.query(
        'chat_messages',
        where: 'moong_id = ? AND created_at >= ? AND created_at <= ?',
        whereArgs: [moongId, startTimestamp, endTimestamp],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting messages in range: $e');
      rethrow;
    }
  }

  // Get message count for a moong
  Future<int> getMessageCount(String moongId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM chat_messages
        WHERE moong_id = ?
      ''', [moongId]);

      if (result.isEmpty) return 0;
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('Error getting message count: $e');
      rethrow;
    }
  }

  // Get user message count (messages sent by user)
  Future<int> getUserMessageCount(String moongId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM chat_messages
        WHERE moong_id = ? AND is_user = 1
      ''', [moongId]);

      if (result.isEmpty) return 0;
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('Error getting user message count: $e');
      rethrow;
    }
  }

  // Get moong message count (messages sent by moong)
  Future<int> getMoongMessageCount(String moongId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM chat_messages
        WHERE moong_id = ? AND is_user = 0
      ''', [moongId]);

      if (result.isEmpty) return 0;
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('Error getting moong message count: $e');
      rethrow;
    }
  }

  // Delete a specific message
  Future<int> deleteMessage(int id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'chat_messages',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }

  // Delete all messages for a moong
  Future<int> deleteMessagesByMoong(String moongId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'chat_messages',
        where: 'moong_id = ?',
        whereArgs: [moongId],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting messages by moong: $e');
      rethrow;
    }
  }

  // Delete all messages for a user
  Future<int> deleteMessagesByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'chat_messages',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting messages by user: $e');
      rethrow;
    }
  }

  // Delete old messages (older than specified date)
  Future<int> deleteOldMessages(DateTime beforeDate) async {
    try {
      final db = await _dbHelper.database;
      final timestamp = beforeDate.millisecondsSinceEpoch;
      
      final result = await db.delete(
        'chat_messages',
        where: 'created_at < ?',
        whereArgs: [timestamp],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting old messages: $e');
      rethrow;
    }
  }

  // Search messages by content
  Future<List<ChatMessage>> searchMessages(
    String moongId,
    String searchTerm,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'chat_messages',
        where: 'moong_id = ? AND message LIKE ?',
        whereArgs: [moongId, '%$searchTerm%'],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error searching messages: $e');
      rethrow;
    }
  }

  // Get today's messages
  Future<List<ChatMessage>> getTodayMessages(String moongId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      return await getMessagesInRange(moongId, startOfDay, endOfDay);
    } catch (e) {
      debugPrint('Error getting today messages: $e');
      rethrow;
    }
  }

  // Get conversation statistics
  Future<Map<String, dynamic>> getConversationStats(String moongId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_messages,
          SUM(CASE WHEN is_user = 1 THEN 1 ELSE 0 END) as user_messages,
          SUM(CASE WHEN is_user = 0 THEN 1 ELSE 0 END) as moong_messages,
          MIN(created_at) as first_message_time,
          MAX(created_at) as last_message_time
        FROM chat_messages
        WHERE moong_id = ?
      ''', [moongId]);

      if (result.isEmpty) {
        return {
          'total_messages': 0,
          'user_messages': 0,
          'moong_messages': 0,
          'first_message_time': null,
          'last_message_time': null,
        };
      }

      final row = result.first;
      return {
        'total_messages': row['total_messages'] as int,
        'user_messages': row['user_messages'] as int,
        'moong_messages': row['moong_messages'] as int,
        'first_message_time': row['first_message_time'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['first_message_time'] as int)
            : null,
        'last_message_time': row['last_message_time'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['last_message_time'] as int)
            : null,
      };
    } catch (e) {
      debugPrint('Error getting conversation stats: $e');
      rethrow;
    }
  }

  // Batch insert multiple messages
  Future<void> insertMessages(List<ChatMessage> messages) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var message in messages) {
        batch.insert(
          'chat_messages',
          message.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error batch inserting messages: $e');
      rethrow;
    }
  }
}
