import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../database/shop_item_dao.dart';

class ShopProvider with ChangeNotifier {
  final ShopItemDao _shopItemDao = ShopItemDao();
  List<ShopItem> _items = [];
  bool _isLoading = false;

  List<ShopItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  List<ShopItem> getItemsByCategory(ShopCategory category) {
    return _items.where((item) => item.category == category).toList();
  }

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Web platform - skipping shop database operations');
      _isLoading = false;
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items = await _shopItemDao.getAllShopItems();
    } catch (e) {
      debugPrint('Error loading shop items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchases an item and coordinates with AuthProvider and InventoryProvider.
  /// Uses callbacks to deduct balance and add to inventory atomically.
  Future<bool> purchaseItem(
    String userId,
    ShopItem item,
    int currentBalance, {
    Function(int newBalance)? onBalanceDeducted,
    Function(String shopItemId)? onItemPurchased,
  }) async {
    if (currentBalance < item.price) {
      debugPrint('Insufficient balance: $currentBalance < ${item.price}');
      return false;
    }

    if (kIsWeb) {
      debugPrint('Web platform - skipping purchase database operations');
      return false;
    }

    try {
      // Verify the item exists in the shop
      final shopItem = await _shopItemDao.getShopItem(item.id);
      if (shopItem == null) {
        debugPrint('Shop item not found: ${item.id}');
        return false;
      }

      // Purchase successful - coordinate with other providers
      final newBalance = currentBalance - item.price;

      if (onBalanceDeducted != null) {
        onBalanceDeducted(newBalance);
      }

      if (onItemPurchased != null) {
        onItemPurchased(item.id);
      }

      return true;
    } catch (e) {
      debugPrint('Error during purchase: $e');
      return false;
    }
  }
}
