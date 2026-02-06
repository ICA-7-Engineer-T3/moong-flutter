import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../database/user_inventory_dao.dart';

class InventoryProvider with ChangeNotifier {
  final UserInventoryDao _inventoryDao = UserInventoryDao();
  List<ShopItem> _ownedItems = [];
  bool _isLoading = false;
  String? _userId;

  List<ShopItem> get ownedItems => List.unmodifiable(_ownedItems);
  bool get isLoading => _isLoading;

  Future<void> initialize(String userId) async {
    if (kIsWeb) {
      debugPrint('Web platform - skipping inventory database operations');
      _isLoading = false;
      return;
    }

    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      _ownedItems = await _inventoryDao.getUserInventoryItems(userId);
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
    if (kIsWeb) {
      debugPrint('Web platform - skipping inventory add');
      return;
    }

    if (_userId == null) {
      debugPrint('Cannot add item: userId is null');
      return;
    }

    try {
      await _inventoryDao.addToInventory(_userId!, shopItemId);
      // Reload inventory to get the full ShopItem with JOIN
      _ownedItems = await _inventoryDao.getUserInventoryItems(_userId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item to inventory: $e');
    }
  }

  List<ShopItem> getInventoryByCategory(ShopCategory category) {
    return _ownedItems.where((item) => item.category == category).toList();
  }
}
