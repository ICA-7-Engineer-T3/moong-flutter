import 'package:moong_flutter/models/shop_item.dart';

/// User inventory item model
class UserInventoryItem {
  final String id;
  final String userId;
  final String shopItemId;
  final DateTime purchasedAt;

  UserInventoryItem({
    required this.id,
    required this.userId,
    required this.shopItemId,
    required this.purchasedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': shopItemId,
      'purchased_at': purchasedAt.toIso8601String(),
    };
  }

  factory UserInventoryItem.fromMap(Map<String, dynamic> map) {
    return UserInventoryItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      shopItemId: map['item_id'] as String,
      purchasedAt: DateTime.parse(map['purchased_at'] as String),
    );
  }

  /// Firestore serialization
  Map<String, dynamic> toFirestore() {
    return {
      'shopItemId': shopItemId,
      'purchasedAt': purchasedAt,
    };
  }

  factory UserInventoryItem.fromFirestore(Map<String, dynamic> data, String id, String userId) {
    return UserInventoryItem(
      id: id,
      userId: userId,
      shopItemId: data['shopItemId'] as String,
      purchasedAt: (data['purchasedAt'] as dynamic).toDate() as DateTime,
    );
  }
}

/// Repository interface for Inventory data operations
abstract class InventoryRepository {
  /// Get inventory item by ID
  Future<UserInventoryItem?> getInventoryItem(String userId, String inventoryId);

  /// Get all inventory items for a user
  Future<List<UserInventoryItem>> getInventoryByUser(String userId);

  /// Get inventory items by category
  Future<List<UserInventoryItem>> getInventoryByCategory(String userId, ShopCategory category);

  /// Check if user owns a specific shop item
  Future<bool> hasItem(String userId, String shopItemId);

  /// Add item to user's inventory
  Future<void> addItem(String userId, String shopItemId);

  /// Remove item from user's inventory
  Future<void> removeItem(String userId, String inventoryId);

  /// Get inventory count for a user
  Future<int> getInventoryCount(String userId);

  /// Get purchase date for a shop item
  Future<DateTime?> getPurchaseDate(String userId, String shopItemId);

  /// Delete all inventory items for a user
  Future<void> clearInventory(String userId);

  /// Get recently purchased items (last N items)
  Future<List<UserInventoryItem>> getRecentPurchases(String userId, int limit);

  /// Add multiple items at once (batch operation)
  Future<void> addItems(String userId, List<String> shopItemIds);

  /// Get total spent by user (requires joining with shop_items)
  Future<int> getTotalSpent(String userId);
}
