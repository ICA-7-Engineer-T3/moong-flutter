import 'package:moong_flutter/models/shop_item.dart';

/// Repository interface for ShopItem data operations
abstract class ShopItemRepository {
  /// Get shop item by ID
  Future<ShopItem?> getShopItem(String itemId);

  /// Get all shop items
  Future<List<ShopItem>> getAllShopItems();

  /// Get shop items by category
  Future<List<ShopItem>> getShopItemsByCategory(ShopCategory category);

  /// Get shop items by currency type
  Future<List<ShopItem>> getShopItemsByCurrency(Currency currency);

  /// Get unlockable shop items (items with unlock days requirement)
  Future<List<ShopItem>> getUnlockableShopItems();

  /// Create a new shop item
  Future<void> createShopItem(ShopItem item);

  /// Update an existing shop item
  Future<void> updateShopItem(ShopItem item);

  /// Delete a shop item
  Future<void> deleteShopItem(String itemId);

  /// Create multiple shop items at once (batch operation)
  Future<void> createShopItems(List<ShopItem> items);

  /// Check if shop item exists
  Future<bool> shopItemExists(String itemId);

  /// Get shop items count
  Future<int> getShopItemsCount();

  /// Delete all shop items (for testing/seeding purposes)
  Future<void> deleteAllShopItems();
}
