import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/shop_item.dart';
import '../services/database_helper.dart';

class UserInventoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add item to user's inventory
  Future<int> addToInventory(String userId, String shopItemId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'user_inventory',
        {
          'user_id': userId,
          'shop_item_id': shopItemId,
          'purchased_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if already exists
      );
      return result;
    } catch (e) {
      debugPrint('Error adding to inventory: $e');
      rethrow;
    }
  }

  // Remove item from user's inventory
  Future<int> removeFromInventory(String userId, String shopItemId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'user_inventory',
        where: 'user_id = ? AND shop_item_id = ?',
        whereArgs: [userId, shopItemId],
      );
      return result;
    } catch (e) {
      debugPrint('Error removing from inventory: $e');
      rethrow;
    }
  }

  // Check if user has a specific item
  Future<bool> hasItem(String userId, String shopItemId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'user_inventory',
        where: 'user_id = ? AND shop_item_id = ?',
        whereArgs: [userId, shopItemId],
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user has item: $e');
      rethrow;
    }
  }

  // Get all item IDs in user's inventory
  Future<List<String>> getUserInventoryIds(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'user_inventory',
        columns: ['shop_item_id'],
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'purchased_at DESC',
      );

      return maps.map((map) => map['shop_item_id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting user inventory IDs: $e');
      rethrow;
    }
  }

  // Get full shop items in user's inventory (with JOIN)
  Future<List<ShopItem>> getUserInventoryItems(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT si.*
        FROM shop_items si
        INNER JOIN user_inventory ui ON si.id = ui.shop_item_id
        WHERE ui.user_id = ?
        ORDER BY ui.purchased_at DESC
      ''', [userId]);

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting user inventory items: $e');
      rethrow;
    }
  }

  // Get inventory items by category
  Future<List<ShopItem>> getUserInventoryByCategory(
    String userId,
    ShopCategory category,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT si.*
        FROM shop_items si
        INNER JOIN user_inventory ui ON si.id = ui.shop_item_id
        WHERE ui.user_id = ? AND si.category = ?
        ORDER BY ui.purchased_at DESC
      ''', [userId, category.toString().split('.').last]);

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting user inventory by category: $e');
      rethrow;
    }
  }

  // Get inventory count for a user
  Future<int> getInventoryCount(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM user_inventory
        WHERE user_id = ?
      ''', [userId]);

      if (result.isEmpty) return 0;
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('Error getting inventory count: $e');
      rethrow;
    }
  }

  // Get purchase date for an item
  Future<DateTime?> getPurchaseDate(String userId, String shopItemId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'user_inventory',
        columns: ['purchased_at'],
        where: 'user_id = ? AND shop_item_id = ?',
        whereArgs: [userId, shopItemId],
      );

      if (maps.isEmpty) return null;
      
      final timestamp = maps.first['purchased_at'] as int;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('Error getting purchase date: $e');
      rethrow;
    }
  }

  // Get recently purchased items
  Future<List<ShopItem>> getRecentlyPurchased(String userId, int limit) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.rawQuery('''
        SELECT si.*
        FROM shop_items si
        INNER JOIN user_inventory ui ON si.id = ui.shop_item_id
        WHERE ui.user_id = ?
        ORDER BY ui.purchased_at DESC
        LIMIT ?
      ''', [userId, limit]);

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting recently purchased items: $e');
      rethrow;
    }
  }

  // Clear all inventory for a user
  Future<int> clearUserInventory(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'user_inventory',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (e) {
      debugPrint('Error clearing user inventory: $e');
      rethrow;
    }
  }

  // Batch add multiple items to inventory
  Future<void> addMultipleToInventory(
    String userId,
    List<String> shopItemIds,
  ) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      final purchasedAt = DateTime.now().millisecondsSinceEpoch;

      for (var itemId in shopItemIds) {
        batch.insert(
          'user_inventory',
          {
            'user_id': userId,
            'shop_item_id': itemId,
            'purchased_at': purchasedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error batch adding to inventory: $e');
      rethrow;
    }
  }

  // Get total value of inventory (by currency)
  Future<Map<String, int>> getInventoryValue(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          si.currency,
          SUM(si.price) as total_value
        FROM shop_items si
        INNER JOIN user_inventory ui ON si.id = ui.shop_item_id
        WHERE ui.user_id = ?
        GROUP BY si.currency
      ''', [userId]);

      final Map<String, int> values = {};
      
      for (var row in result) {
        final currency = row['currency'] as String;
        final totalValue = row['total_value'] as int;
        values[currency] = totalValue;
      }

      return values;
    } catch (e) {
      debugPrint('Error getting inventory value: $e');
      rethrow;
    }
  }

  // Get items purchased within a date range
  Future<List<ShopItem>> getItemsPurchasedInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final startTimestamp = startDate.millisecondsSinceEpoch;
      final endTimestamp = endDate.millisecondsSinceEpoch;

      final maps = await db.rawQuery('''
        SELECT si.*
        FROM shop_items si
        INNER JOIN user_inventory ui ON si.id = ui.shop_item_id
        WHERE ui.user_id = ? 
          AND ui.purchased_at >= ? 
          AND ui.purchased_at <= ?
        ORDER BY ui.purchased_at DESC
      ''', [userId, startTimestamp, endTimestamp]);

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting items purchased in range: $e');
      rethrow;
    }
  }
}
