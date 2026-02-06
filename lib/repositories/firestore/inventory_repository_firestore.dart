import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moong_flutter/models/shop_item.dart';
import 'package:moong_flutter/repositories/interfaces/inventory_repository.dart';

/// Firestore implementation of InventoryRepository
class InventoryRepositoryFirestore implements InventoryRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';
  static const String _inventorySubcollection = 'inventory';
  static const String _shopItemsCollection = 'shopItems';

  InventoryRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _inventoryCollection(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_inventorySubcollection);
  }

  @override
  Future<UserInventoryItem?> getInventoryItem(String userId, String inventoryId) async {
    try {
      final doc = await _inventoryCollection(userId).doc(inventoryId).get();
      if (!doc.exists) return null;
      return UserInventoryItem.fromFirestore(doc.data()!, doc.id, userId);
    } catch (e) {
      throw Exception('Failed to get inventory item: $e');
    }
  }

  @override
  Future<List<UserInventoryItem>> getInventoryByUser(String userId) async {
    try {
      final snapshot = await _inventoryCollection(userId)
          .orderBy('purchasedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => UserInventoryItem.fromFirestore(doc.data(), doc.id, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get inventory by user: $e');
    }
  }

  @override
  Future<List<UserInventoryItem>> getInventoryByCategory(
      String userId, ShopCategory category) async {
    try {
      final inventoryItems = await getInventoryByUser(userId);
      final shopItemIds = inventoryItems.map((item) => item.shopItemId).toList();

      if (shopItemIds.isEmpty) return [];

      final shopItemsSnapshot = await _firestore
          .collection(_shopItemsCollection)
          .where(FieldPath.documentId, whereIn: shopItemIds)
          .where('category', isEqualTo: category.name)
          .get();

      final matchingShopItemIds =
          shopItemsSnapshot.docs.map((doc) => doc.id).toSet();

      return inventoryItems
          .where((item) => matchingShopItemIds.contains(item.shopItemId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get inventory by category: $e');
    }
  }

  @override
  Future<bool> hasItem(String userId, String shopItemId) async {
    try {
      final snapshot = await _inventoryCollection(userId)
          .where('shopItemId', isEqualTo: shopItemId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if user has item: $e');
    }
  }

  @override
  Future<void> addItem(String userId, String shopItemId) async {
    try {
      await _inventoryCollection(userId).add({
        'shopItemId': shopItemId,
        'purchasedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add item to inventory: $e');
    }
  }

  @override
  Future<void> removeItem(String userId, String inventoryId) async {
    try {
      await _inventoryCollection(userId).doc(inventoryId).delete();
    } catch (e) {
      throw Exception('Failed to remove item from inventory: $e');
    }
  }

  @override
  Future<int> getInventoryCount(String userId) async {
    try {
      final snapshot = await _inventoryCollection(userId).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get inventory count: $e');
    }
  }

  @override
  Future<DateTime?> getPurchaseDate(String userId, String shopItemId) async {
    try {
      final snapshot = await _inventoryCollection(userId)
          .where('shopItemId', isEqualTo: shopItemId)
          .orderBy('purchasedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      return (data['purchasedAt'] as Timestamp).toDate();
    } catch (e) {
      throw Exception('Failed to get purchase date: $e');
    }
  }

  @override
  Future<void> clearInventory(String userId) async {
    try {
      final snapshot = await _inventoryCollection(userId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear inventory: $e');
    }
  }

  @override
  Future<List<UserInventoryItem>> getRecentPurchases(String userId, int limit) async {
    try {
      final snapshot = await _inventoryCollection(userId)
          .orderBy('purchasedAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => UserInventoryItem.fromFirestore(doc.data(), doc.id, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent purchases: $e');
    }
  }

  @override
  Future<void> addItems(String userId, List<String> shopItemIds) async {
    try {
      final batch = _firestore.batch();
      final timestamp = Timestamp.now();

      for (final shopItemId in shopItemIds) {
        final docRef = _inventoryCollection(userId).doc();
        batch.set(docRef, {
          'shopItemId': shopItemId,
          'purchasedAt': timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add items batch: $e');
    }
  }

  @override
  Future<int> getTotalSpent(String userId) async {
    try {
      final inventoryItems = await getInventoryByUser(userId);
      if (inventoryItems.isEmpty) return 0;

      final shopItemIds = inventoryItems.map((item) => item.shopItemId).toList();

      int total = 0;
      for (int i = 0; i < shopItemIds.length; i += 10) {
        final batch = shopItemIds.skip(i).take(10).toList();
        final shopItemsSnapshot = await _firestore
            .collection(_shopItemsCollection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in shopItemsSnapshot.docs) {
          total += (doc.data()['price'] as int?) ?? 0;
        }
      }

      return total;
    } catch (e) {
      throw Exception('Failed to get total spent: $e');
    }
  }
}
