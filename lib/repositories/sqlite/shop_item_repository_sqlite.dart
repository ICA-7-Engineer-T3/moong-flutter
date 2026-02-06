import 'package:moong_flutter/database/shop_item_dao.dart';
import 'package:moong_flutter/models/shop_item.dart';
import 'package:moong_flutter/repositories/interfaces/shop_item_repository.dart';

/// SQLite implementation of ShopItemRepository
/// Wraps ShopItemDao to conform to repository interface
class ShopItemRepositorySQLite implements ShopItemRepository {
  final ShopItemDao _dao = ShopItemDao();

  @override
  Future<ShopItem?> getShopItem(String itemId) =>
      _dao.getShopItem(itemId);

  @override
  Future<List<ShopItem>> getAllShopItems() =>
      _dao.getAllShopItems();

  @override
  Future<List<ShopItem>> getShopItemsByCategory(ShopCategory category) =>
      _dao.getShopItemsByCategory(category);

  @override
  Future<List<ShopItem>> getShopItemsByCurrency(Currency currency) =>
      _dao.getItemsByCurrency(currency);

  @override
  Future<List<ShopItem>> getUnlockableShopItems() async {
    // Get all items and filter those with unlockDays
    final allItems = await _dao.getAllShopItems();
    return allItems.where((item) => item.unlockDays != null).toList();
  }

  @override
  Future<void> createShopItem(ShopItem item) async {
    await _dao.insertShopItem(item);
  }

  @override
  Future<void> updateShopItem(ShopItem item) async {
    await _dao.updateShopItem(item);
  }

  @override
  Future<void> deleteShopItem(String itemId) async {
    await _dao.deleteShopItem(itemId);
  }

  @override
  Future<void> createShopItems(List<ShopItem> items) async {
    for (var item in items) {
      await _dao.insertShopItem(item);
    }
  }

  @override
  Future<bool> shopItemExists(String itemId) =>
      _dao.shopItemExists(itemId);

  @override
  Future<int> getShopItemsCount() async {
    final items = await _dao.getAllShopItems();
    return items.length;
  }

  @override
  Future<void> deleteAllShopItems() async {
    await _dao.clearAllShopItems();
  }
}
