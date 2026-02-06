import 'package:moong_flutter/database/user_inventory_dao.dart';
import 'package:moong_flutter/models/shop_item.dart';
import 'package:moong_flutter/repositories/interfaces/inventory_repository.dart';

/// SQLite implementation of InventoryRepository
/// Wraps UserInventoryDao to conform to repository interface
class InventoryRepositorySQLite implements InventoryRepository {
  final UserInventoryDao _dao = UserInventoryDao();

  @override
  Future<UserInventoryItem?> getInventoryItem(String userId, String inventoryId) async {
    // Note: UserInventoryDao returns ShopItems, not UserInventoryItems
    // We'll need to construct them from the data
    // For now, return null as we need more DAO support
    return null;
  }

  @override
  Future<List<UserInventoryItem>> getInventoryByUser(String userId) async {
    // Note: UserInventoryDao returns ShopItems, need to adapt
    // For now, return empty list as we need the full inventory data
    return [];
  }

  @override
  Future<List<UserInventoryItem>> getInventoryByCategory(String userId, ShopCategory category) async {
    // Return empty for now as we need full inventory item data
    return [];
  }

  @override
  Future<bool> hasItem(String userId, String shopItemId) =>
      _dao.hasItem(userId, shopItemId);

  @override
  Future<void> addItem(String userId, String shopItemId) async {
    await _dao.addToInventory(userId, shopItemId);
  }

  @override
  Future<void> removeItem(String userId, String inventoryId) async {
    // Note: DAO uses shopItemId, not inventory record ID
    await _dao.removeFromInventory(userId, inventoryId);
  }

  @override
  Future<int> getInventoryCount(String userId) =>
      _dao.getInventoryCount(userId);

  @override
  Future<DateTime?> getPurchaseDate(String userId, String shopItemId) =>
      _dao.getPurchaseDate(userId, shopItemId);

  @override
  Future<void> clearInventory(String userId) async {
    await _dao.clearUserInventory(userId);
  }

  @override
  Future<List<UserInventoryItem>> getRecentPurchases(String userId, int limit) async {
    // Return empty for now
    return [];
  }

  @override
  Future<void> addItems(String userId, List<String> shopItemIds) async {
    await _dao.addMultipleToInventory(userId, shopItemIds);
  }

  @override
  Future<int> getTotalSpent(String userId) async {
    final value = await _dao.getInventoryValue(userId);
    return value['total_sprouts'] ?? 0;
  }
}
