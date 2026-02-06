import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moong_flutter/models/shop_item.dart';
import 'package:moong_flutter/repositories/interfaces/shop_item_repository.dart';

/// Firestore implementation of ShopItemRepository
class ShopItemRepositoryFirestore implements ShopItemRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'shopItems';

  ShopItemRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _shopItemsCollection {
    return _firestore.collection(_collection);
  }

  @override
  Future<ShopItem?> getShopItem(String itemId) async {
    try {
      final doc = await _shopItemsCollection.doc(itemId).get();
      if (!doc.exists) return null;
      return ShopItem.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get shop item: $e');
    }
  }

  @override
  Future<List<ShopItem>> getAllShopItems() async {
    try {
      final snapshot = await _shopItemsCollection.orderBy('name').get();
      return snapshot.docs.map((doc) => ShopItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all shop items: $e');
    }
  }

  @override
  Future<List<ShopItem>> getShopItemsByCategory(ShopCategory category) async {
    try {
      final snapshot = await _shopItemsCollection
          .where('category', isEqualTo: category.name)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => ShopItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get shop items by category: $e');
    }
  }

  @override
  Future<List<ShopItem>> getShopItemsByCurrency(Currency currency) async {
    try {
      final snapshot = await _shopItemsCollection
          .where('currency', isEqualTo: currency.name)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => ShopItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get shop items by currency: $e');
    }
  }

  @override
  Future<List<ShopItem>> getUnlockableShopItems() async {
    try {
      final snapshot = await _shopItemsCollection
          .where('unlockDays', isNull: false)
          .orderBy('unlockDays')
          .get();
      return snapshot.docs.map((doc) => ShopItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get unlockable shop items: $e');
    }
  }

  @override
  Future<void> createShopItem(ShopItem item) async {
    try {
      await _shopItemsCollection.doc(item.id).set(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to create shop item: $e');
    }
  }

  @override
  Future<void> updateShopItem(ShopItem item) async {
    try {
      await _shopItemsCollection.doc(item.id).update(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to update shop item: $e');
    }
  }

  @override
  Future<void> deleteShopItem(String itemId) async {
    try {
      await _shopItemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete shop item: $e');
    }
  }

  @override
  Future<void> createShopItems(List<ShopItem> items) async {
    try {
      final batch = _firestore.batch();
      for (final item in items) {
        final docRef = _shopItemsCollection.doc(item.id);
        batch.set(docRef, item.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create shop items batch: $e');
    }
  }

  @override
  Future<bool> shopItemExists(String itemId) async {
    try {
      final doc = await _shopItemsCollection.doc(itemId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if shop item exists: $e');
    }
  }

  @override
  Future<int> getShopItemsCount() async {
    try {
      final snapshot = await _shopItemsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get shop items count: $e');
    }
  }

  @override
  Future<void> deleteAllShopItems() async {
    try {
      final snapshot = await _shopItemsCollection.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all shop items: $e');
    }
  }
}
