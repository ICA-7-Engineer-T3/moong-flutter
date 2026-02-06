import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../repositories/interfaces/inventory_repository.dart';
import '../repositories/interfaces/shop_item_repository.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  final ShopItemRepository _shopItemRepository;
  List<ShopItem> _ownedItems = [];
  bool _isLoading = false;
  String? _userId;

  List<ShopItem> get ownedItems => List.unmodifiable(_ownedItems);
  bool get isLoading => _isLoading;

  InventoryProvider({
    required InventoryRepository inventoryRepository,
    required ShopItemRepository shopItemRepository,
  })  : _inventoryRepository = inventoryRepository,
        _shopItemRepository = shopItemRepository;

  Future<void> initialize(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      // Get inventory items (just the references)
      final inventoryItems = await _inventoryRepository.getInventoryByUser(userId);

      // Fetch full shop item details for each inventory item
      _ownedItems = [];
      for (final invItem in inventoryItems) {
        final shopItem = await _shopItemRepository.getShopItem(invItem.shopItemId);
        if (shopItem != null) {
          _ownedItems.add(shopItem);
        }
      }
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasItem(String shopItemId) {
    return _ownedItems.any((item) => item.id == shopItemId);
  }

  Future<void> addItem(String shopItemId) async {
    if (_userId == null) {
      debugPrint('Cannot add item: userId is null');
      return;
    }

    try {
      await _inventoryRepository.addItem(_userId!, shopItemId);

      // Fetch the shop item details and add to list
      final shopItem = await _shopItemRepository.getShopItem(shopItemId);
      if (shopItem != null) {
        _ownedItems = [..._ownedItems, shopItem];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding item to inventory: $e');
      rethrow;
    }
  }

  List<ShopItem> getInventoryByCategory(ShopCategory category) {
    return _ownedItems.where((item) => item.category == category).toList();
  }
}
