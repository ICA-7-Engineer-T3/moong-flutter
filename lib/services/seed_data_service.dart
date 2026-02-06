import 'package:flutter/foundation.dart';
import '../models/shop_item.dart';
import '../database/shop_item_dao.dart';

class SeedDataService {
  final ShopItemDao _shopItemDao = ShopItemDao();

  // Seed shop items if not already seeded
  Future<void> seedShopItems() async {
    try {
      // Check if shop items already exist
      final existingItems = await _shopItemDao.getAllShopItems();
      if (existingItems.isNotEmpty) {
        return; // Already seeded
      }

      // Create sample shop items
      final items = [
        // Clothes
        ShopItem(
          id: 'clothes_1',
          category: ShopCategory.clothes,
          name: '빨간 모자',
          price: 100,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'clothes_2',
          category: ShopCategory.clothes,
          name: '파란 티셔츠',
          price: 150,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'clothes_3',
          category: ShopCategory.clothes,
          name: '검은 바지',
          price: 200,
          currency: Currency.sprout,
        ),
        
        // Accessories
        ShopItem(
          id: 'acc_1',
          category: ShopCategory.accessories,
          name: '선글라스',
          price: 80,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'acc_2',
          category: ShopCategory.accessories,
          name: '목걸이',
          price: 120,
          currency: Currency.credit,
        ),
        ShopItem(
          id: 'acc_3',
          category: ShopCategory.accessories,
          name: '시계',
          price: 300,
          currency: Currency.credit,
        ),
        
        // Furniture
        ShopItem(
          id: 'furniture_1',
          category: ShopCategory.furniture,
          name: '작은 책상',
          price: 500,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'furniture_2',
          category: ShopCategory.furniture,
          name: '편안한 의자',
          price: 400,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'furniture_3',
          category: ShopCategory.furniture,
          name: '책장',
          price: 600,
          currency: Currency.credit,
        ),
        
        // Backgrounds
        ShopItem(
          id: 'bg_1',
          category: ShopCategory.background,
          name: '숲 배경',
          price: 250,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'bg_2',
          category: ShopCategory.background,
          name: '해변 배경',
          price: 300,
          currency: Currency.sprout,
        ),
        ShopItem(
          id: 'bg_3',
          category: ShopCategory.background,
          name: '우주 배경',
          price: 400,
          currency: Currency.credit,
        ),
        ShopItem(
          id: 'bg_4',
          category: ShopCategory.background,
          name: '벚꽃 배경',
          price: 350,
          currency: Currency.credit,
        ),
        
        // Season items (locked)
        ShopItem(
          id: 'season_1',
          category: ShopCategory.season,
          name: '크리스마스 모자',
          price: 500,
          currency: Currency.credit,
          unlockDays: 30,
        ),
        ShopItem(
          id: 'season_2',
          category: ShopCategory.season,
          name: '할로윈 의상',
          price: 600,
          currency: Currency.credit,
          unlockDays: 60,
        ),
        ShopItem(
          id: 'season_3',
          category: ShopCategory.season,
          name: '여름 수영복',
          price: 400,
          currency: Currency.credit,
          unlockDays: 90,
        ),
      ];

      // Batch insert all items
      await _shopItemDao.insertShopItems(items);
      
      debugPrint('Successfully seeded ${items.length} shop items');
    } catch (e) {
      debugPrint('Error seeding shop items: $e');
      rethrow;
    }
  }

  // Clear all shop items (for testing)
  Future<void> clearShopItems() async {
    await _shopItemDao.clearAllShopItems();
    debugPrint('Cleared all shop items');
  }

  // Re-seed shop items (clear and seed again)
  Future<void> reseedShopItems() async {
    await clearShopItems();
    await seedShopItems();
  }
}
