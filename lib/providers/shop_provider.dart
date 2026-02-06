import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../repositories/interfaces/shop_item_repository.dart';

class ShopProvider with ChangeNotifier {
  final ShopItemRepository _shopItemRepository;
  List<ShopItem> _items = [];
  bool _isLoading = false;

  List<ShopItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  ShopProvider({required ShopItemRepository shopItemRepository})
      : _shopItemRepository = shopItemRepository;

  List<ShopItem> getItemsByCategory(ShopCategory category) {
    return _items.where((item) => item.category == category).toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _shopItemRepository.getAllShopItems();
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

    try {
      // Verify the item exists in the shop
      final shopItem = await _shopItemRepository.getShopItem(item.id);
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
      rethrow;
    }
  }
}
