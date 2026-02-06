import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/shop_item.dart';
import '../services/database_helper.dart';

class ShopItemDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert a new shop item
  Future<int> insertShopItem(ShopItem item) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'shop_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result;
    } catch (e) {
      debugPrint('Error inserting shop item: $e');
      rethrow;
    }
  }

  // Update an existing shop item
  Future<int> updateShopItem(ShopItem item) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'shop_items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      return result;
    } catch (e) {
      debugPrint('Error updating shop item: $e');
      rethrow;
    }
  }

  // Get a shop item by ID
  Future<ShopItem?> getShopItem(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'shop_items',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return ShopItem.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting shop item: $e');
      rethrow;
    }
  }

  // Get all shop items
  Future<List<ShopItem>> getAllShopItems() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'shop_items',
        orderBy: 'category, name',
      );

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting all shop items: $e');
      rethrow;
    }
  }

  // Get shop items by category
  Future<List<ShopItem>> getShopItemsByCategory(ShopCategory category) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'shop_items',
        where: 'category = ?',
        whereArgs: [category.name],
        orderBy: 'name',
      );

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting shop items by category: $e');
      rethrow;
    }
  }

  // Get available shop items (considering unlock days)
  Future<List<ShopItem>> getAvailableItems(int currentDay) async {
    try {
      final db = await _dbHelper.database;
      // Get items that are either always available (unlock_days is NULL)
      // or available based on current day (unlock_days <= currentDay)
      final maps = await db.query(
        'shop_items',
        where: 'unlock_days IS NULL OR unlock_days <= ?',
        whereArgs: [currentDay],
        orderBy: 'category, name',
      );

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting available items: $e');
      rethrow;
    }
  }

  // Get available items by category
  Future<List<ShopItem>> getAvailableItemsByCategory(
    ShopCategory category,
    int currentDay,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'shop_items',
        where: 'category = ? AND (unlock_days IS NULL OR unlock_days <= ?)',
        whereArgs: [category.name, currentDay],
        orderBy: 'name',
      );

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting available items by category: $e');
      rethrow;
    }
  }

  // Get items by currency type
  Future<List<ShopItem>> getItemsByCurrency(Currency currency) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'shop_items',
        where: 'currency = ?',
        whereArgs: [currency.name],
        orderBy: 'price',
      );

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting items by currency: $e');
      rethrow;
    }
  }

  // Get items within price range
  Future<List<ShopItem>> getItemsByPriceRange(
    int minPrice,
    int maxPrice,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'shop_items',
        where: 'price >= ? AND price <= ?',
        whereArgs: [minPrice, maxPrice],
        orderBy: 'price',
      );

      return maps.map((map) => ShopItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting items by price range: $e');
      rethrow;
    }
  }

  // Delete a shop item
  Future<int> deleteShopItem(String id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'shop_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting shop item: $e');
      rethrow;
    }
  }

  // Delete all shop items in a category
  Future<int> deleteShopItemsByCategory(ShopCategory category) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'shop_items',
        where: 'category = ?',
        whereArgs: [category.name],
      );
      return result;
    } catch (e) {
      debugPrint('Error deleting shop items by category: $e');
      rethrow;
    }
  }

  // Check if shop item exists
  Future<bool> shopItemExists(String id) async {
    try {
      final item = await getShopItem(id);
      return item != null;
    } catch (e) {
      debugPrint('Error checking if shop item exists: $e');
      rethrow;
    }
  }

  // Get item count by category
  Future<int> getItemCountByCategory(ShopCategory category) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM shop_items
        WHERE category = ?
      ''', [category.name]);

      if (result.isEmpty) return 0;
      return result.first['count'] as int;
    } catch (e) {
      debugPrint('Error getting item count by category: $e');
      rethrow;
    }
  }

  // Batch insert multiple shop items
  Future<void> insertShopItems(List<ShopItem> items) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var item in items) {
        batch.insert(
          'shop_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error batch inserting shop items: $e');
      rethrow;
    }
  }

  // Clear all shop items (useful for re-seeding)
  Future<int> clearAllShopItems() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete('shop_items');
      return result;
    } catch (e) {
      debugPrint('Error clearing all shop items: $e');
      rethrow;
    }
  }
}
