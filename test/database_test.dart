import 'package:flutter_test/flutter_test.dart';
import 'package:moong_flutter/services/database_helper.dart';
import 'package:moong_flutter/database/user_dao.dart';
import 'package:moong_flutter/database/moong_dao.dart';
import 'package:moong_flutter/database/quest_dao.dart';
import 'package:moong_flutter/database/shop_item_dao.dart';
import 'package:moong_flutter/database/user_inventory_dao.dart';
import 'package:moong_flutter/database/chat_message_dao.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/models/moong.dart';
import 'package:moong_flutter/models/quest.dart';
import 'package:moong_flutter/models/shop_item.dart';
import 'package:moong_flutter/models/chat_message.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite_ffi for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;
  late UserDao userDao;
  late MoongDao moongDao;
  late QuestDao questDao;
  late ShopItemDao shopItemDao;
  late UserInventoryDao userInventoryDao;
  late ChatMessageDao chatMessageDao;

  setUp(() async {
    // Initialize database and DAOs before each test
    dbHelper = DatabaseHelper.instance;
    userDao = UserDao();
    moongDao = MoongDao();
    questDao = QuestDao();
    shopItemDao = ShopItemDao();
    userInventoryDao = UserInventoryDao();
    chatMessageDao = ChatMessageDao();

    // Delete any existing database to start fresh
    await dbHelper.deleteDb();
  });

  tearDown(() async {
    // Clean up after each test
    await dbHelper.deleteDb();
  });

  group('DatabaseHelper Tests', () {
    test('Database should be initialized successfully', () async {
      final db = await dbHelper.database;
      expect(db.isOpen, true);
    });

    test('All tables should be created', () async {
      final db = await dbHelper.database;
      
      // Query sqlite_master to check if tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
      );
      
      final tableNames = tables.map((t) => t['name']).toList();
      
      expect(tableNames, contains('users'));
      expect(tableNames, contains('moongs'));
      expect(tableNames, contains('quests'));
      expect(tableNames, contains('shop_items'));
      expect(tableNames, contains('user_inventory'));
      expect(tableNames, contains('chat_messages'));
    });
  });

  group('UserDao Tests', () {
    test('Insert and retrieve user', () async {
      final user = User(
        id: 'test_user_1',
        nickname: 'TestUser',
        level: 1,
        credits: 250,
        sprouts: 250,
      );

      await userDao.insertUser(user);
      final retrievedUser = await userDao.getUser('test_user_1');

      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.id, user.id);
      expect(retrievedUser.nickname, user.nickname);
      expect(retrievedUser.level, user.level);
      expect(retrievedUser.credits, user.credits);
      expect(retrievedUser.sprouts, user.sprouts);
    });

    test('Update user', () async {
      final user = User(
        id: 'test_user_2',
        nickname: 'TestUser2',
        level: 1,
        credits: 250,
        sprouts: 250,
      );

      await userDao.insertUser(user);
      
      final updatedUser = user.copyWith(
        nickname: 'UpdatedUser',
        level: 5,
        credits: 500,
      );
      
      await userDao.updateUser(updatedUser);
      final retrievedUser = await userDao.getUser('test_user_2');

      expect(retrievedUser!.nickname, 'UpdatedUser');
      expect(retrievedUser.level, 5);
      expect(retrievedUser.credits, 500);
    });

    test('Delete user', () async {
      final user = User(
        id: 'test_user_3',
        nickname: 'TestUser3',
      );

      await userDao.insertUser(user);
      await userDao.deleteUser('test_user_3');
      final retrievedUser = await userDao.getUser('test_user_3');

      expect(retrievedUser, isNull);
    });

    test('Get current user returns most recent', () async {
      final user1 = User(
        id: 'user_1',
        nickname: 'User1',
      );
      
      await userDao.insertUser(user1);
      await Future.delayed(const Duration(milliseconds: 100));
      
      final user2 = User(
        id: 'user_2',
        nickname: 'User2',
      );
      
      await userDao.insertUser(user2);
      
      final currentUser = await userDao.getCurrentUser();
      expect(currentUser!.id, 'user_2');
    });
  });

  group('MoongDao Tests', () {
    late User testUser;

    setUp(() async {
      // Create a test user for moong tests
      testUser = User(
        id: 'test_user_moong',
        nickname: 'MoongTestUser',
      );
      await userDao.insertUser(testUser);
    });

    test('Insert and retrieve moong', () async {
      final moong = Moong(
        id: 'moong_1',
        userId: testUser.id,
        name: 'TestMoong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );

      await moongDao.insertMoong(moong);
      final retrievedMoong = await moongDao.getMoong('moong_1');

      expect(retrievedMoong, isNotNull);
      expect(retrievedMoong!.id, moong.id);
      expect(retrievedMoong.userId, moong.userId);
      expect(retrievedMoong.name, moong.name);
      expect(retrievedMoong.type, moong.type);
      expect(retrievedMoong.isActive, true);
    });

    test('Get moongs by user ID', () async {
      final moong1 = Moong(
        id: 'moong_1',
        userId: testUser.id,
        name: 'Moong1',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );

      final moong2 = Moong(
        id: 'moong_2',
        userId: testUser.id,
        name: 'Moong2',
        type: MoongType.mate,
        createdAt: DateTime.now(),
      );

      await moongDao.insertMoong(moong1);
      await moongDao.insertMoong(moong2);

      final moongs = await moongDao.getMoongsByUserId(testUser.id);
      expect(moongs.length, 2);
    });

    test('Get active moongs', () async {
      final activeMoong = Moong(
        id: 'active_moong',
        userId: testUser.id,
        name: 'ActiveMoong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final inactiveMoong = Moong(
        id: 'inactive_moong',
        userId: testUser.id,
        name: 'InactiveMoong',
        type: MoongType.mate,
        createdAt: DateTime.now(),
        isActive: false,
        graduatedAt: DateTime.now(),
      );

      await moongDao.insertMoong(activeMoong);
      await moongDao.insertMoong(inactiveMoong);

      final activeMoongs = await moongDao.getActiveMoongs(testUser.id);
      expect(activeMoongs.length, 1);
      expect(activeMoongs.first.id, 'active_moong');
    });

    test('Update moong', () async {
      final moong = Moong(
        id: 'moong_update',
        userId: testUser.id,
        name: 'UpdateTestMoong',
        type: MoongType.pet,
        level: 1,
        intimacy: 0,
        createdAt: DateTime.now(),
      );

      await moongDao.insertMoong(moong);

      final updatedMoong = moong.copyWith(
        level: 5,
        intimacy: 100,
      );

      await moongDao.updateMoong(updatedMoong);
      final retrievedMoong = await moongDao.getMoong('moong_update');

      expect(retrievedMoong!.level, 5);
      expect(retrievedMoong.intimacy, 100);
    });

    test('Delete moong when user is deleted (CASCADE)', () async {
      final moong = Moong(
        id: 'cascade_moong',
        userId: testUser.id,
        name: 'CascadeMoong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );

      await moongDao.insertMoong(moong);
      
      // Delete the user
      await userDao.deleteUser(testUser.id);
      
      // Moong should also be deleted due to CASCADE
      final retrievedMoong = await moongDao.getMoong('cascade_moong');
      expect(retrievedMoong, isNull);
    });
  });

  group('QuestDao Tests', () {
    late User testUser;
    late Moong testMoong;

    setUp(() async {
      testUser = User(id: 'user_quest', nickname: 'QuestUser');
      await userDao.insertUser(testUser);

      testMoong = Moong(
        id: 'moong_quest',
        userId: testUser.id,
        name: 'QuestMoong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );
      await moongDao.insertMoong(testMoong);
    });

    test('Insert and retrieve quest', () async {
      final quest = Quest(
        id: 'quest_1',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        progress: 0,
        createdAt: DateTime.now(),
      );

      await questDao.insertQuest(quest);
      final retrieved = await questDao.getQuest('quest_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, quest.id);
      expect(retrieved.userId, testUser.id);
      expect(retrieved.type, QuestType.walk);
      expect(retrieved.target, 3000);
      expect(retrieved.progress, 0);
      expect(retrieved.completed, false);
    });

    test('Update quest progress', () async {
      final quest = Quest(
        id: 'quest_progress',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        progress: 0,
        createdAt: DateTime.now(),
      );

      await questDao.insertQuest(quest);
      await questDao.updateQuestProgress('quest_progress', 1500);

      final retrieved = await questDao.getQuest('quest_progress');
      expect(retrieved!.progress, 1500);
    });

    test('Complete quest', () async {
      final quest = Quest(
        id: 'quest_complete',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        progress: 3000,
        createdAt: DateTime.now(),
      );

      await questDao.insertQuest(quest);
      await questDao.completeQuest('quest_complete');

      final retrieved = await questDao.getQuest('quest_complete');
      expect(retrieved!.completed, true);
      expect(retrieved.completedAt, isNotNull);
    });

    test('Get active quests', () async {
      final activeQuest = Quest(
        id: 'active_1',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        progress: 1000,
        completed: false,
        createdAt: DateTime.now(),
      );

      final completedQuest = Quest(
        id: 'completed_1',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        progress: 3000,
        completed: true,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      await questDao.insertQuest(activeQuest);
      await questDao.insertQuest(completedQuest);

      final active = await questDao.getActiveQuests(testUser.id);
      expect(active.length, 1);
      expect(active.first.id, 'active_1');
    });

    test('Get completed quests', () async {
      final completedQuest = Quest(
        id: 'completed_2',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        progress: 3000,
        completed: true,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      await questDao.insertQuest(completedQuest);

      final completed = await questDao.getCompletedQuests(testUser.id);
      expect(completed.length, 1);
      expect(completed.first.completed, true);
    });

    test('Get completion rate', () async {
      await questDao.insertQuest(Quest(
        id: 'q1',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        completed: true,
        createdAt: DateTime.now(),
      ));

      await questDao.insertQuest(Quest(
        id: 'q2',
        userId: testUser.id,
        type: QuestType.walk,
        target: 3000,
        completed: false,
        createdAt: DateTime.now(),
      ));

      final rate = await questDao.getCompletionRate(testUser.id);
      expect(rate, closeTo(0.5, 0.01));
    });

    test('Batch insert quests', () async {
      final quests = [
        Quest(
          id: 'batch_1',
          userId: testUser.id,
          type: QuestType.walk,
          target: 3000,
          createdAt: DateTime.now(),
        ),
        Quest(
          id: 'batch_2',
          userId: testUser.id,
          type: QuestType.walk,
          target: 7000,
          createdAt: DateTime.now(),
        ),
      ];

      await questDao.insertQuests(quests);
      final retrieved = await questDao.getQuestsByUserId(testUser.id);
      expect(retrieved.length, 2);
    });
  });

  group('ShopItemDao Tests', () {
    test('Insert and retrieve shop item', () async {
      final item = ShopItem(
        id: 'item_1',
        name: 'Test Item',
        category: ShopCategory.clothes,
        price: 100,
        currency: Currency.sprout,
      );

      await shopItemDao.insertShopItem(item);
      final retrieved = await shopItemDao.getShopItem('item_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'item_1');
      expect(retrieved.name, 'Test Item');
      expect(retrieved.category, ShopCategory.clothes);
      expect(retrieved.price, 100);
      expect(retrieved.currency, Currency.sprout);
    });

    test('Get shop items by category', () async {
      await shopItemDao.insertShopItem(ShopItem(
        id: 'clothes_1',
        name: 'Clothes 1',
        category: ShopCategory.clothes,
        price: 50,
        currency: Currency.sprout,
      ));

      await shopItemDao.insertShopItem(ShopItem(
        id: 'background_1',
        name: 'Background 1',
        category: ShopCategory.background,
        price: 200,
        currency: Currency.credit,
      ));

      final clothesItems = await shopItemDao.getShopItemsByCategory(ShopCategory.clothes);
      expect(clothesItems.length, 1);
      expect(clothesItems.first.category, ShopCategory.clothes);
    });

    test('Get available items by day', () async {
      await shopItemDao.insertShopItem(ShopItem(
        id: 'early_1',
        name: 'Early Item',
        category: ShopCategory.accessories,
        price: 50,
        currency: Currency.sprout,
        unlockDays: 1,
      ));

      await shopItemDao.insertShopItem(ShopItem(
        id: 'late_1',
        name: 'Late Item',
        category: ShopCategory.accessories,
        price: 100,
        currency: Currency.sprout,
        unlockDays: 10,
      ));

      final day5Items = await shopItemDao.getAvailableItems(5);
      expect(day5Items.length, 1);
      expect(day5Items.first.id, 'early_1');
    });

    test('Get items by currency', () async {
      await shopItemDao.insertShopItem(ShopItem(
        id: 'sprout_1',
        name: 'Sprout Item',
        category: ShopCategory.clothes,
        price: 50,
        currency: Currency.sprout,
      ));

      await shopItemDao.insertShopItem(ShopItem(
        id: 'credit_1',
        name: 'Credit Item',
        category: ShopCategory.background,
        price: 200,
        currency: Currency.credit,
      ));

      final sproutItems = await shopItemDao.getItemsByCurrency(Currency.sprout);
      expect(sproutItems.length, 1);
      expect(sproutItems.first.currency, Currency.sprout);
    });

    test('Get items by price range', () async {
      await shopItemDao.insertShopItem(ShopItem(
        id: 'cheap_1',
        name: 'Cheap',
        category: ShopCategory.clothes,
        price: 50,
        currency: Currency.sprout,
      ));

      await shopItemDao.insertShopItem(ShopItem(
        id: 'expensive_1',
        name: 'Expensive',
        category: ShopCategory.background,
        price: 500,
        currency: Currency.credit,
      ));

      final midRange = await shopItemDao.getItemsByPriceRange(40, 100);
      expect(midRange.length, 1);
      expect(midRange.first.id, 'cheap_1');
    });

    test('Get item count by category', () async {
      await shopItemDao.insertShopItem(ShopItem(
        id: 'clothes_1',
        name: 'Clothes 1',
        category: ShopCategory.clothes,
        price: 50,
        currency: Currency.sprout,
      ));

      await shopItemDao.insertShopItem(ShopItem(
        id: 'clothes_2',
        name: 'Clothes 2',
        category: ShopCategory.clothes,
        price: 60,
        currency: Currency.sprout,
      ));

      final count = await shopItemDao.getItemCountByCategory(ShopCategory.clothes);
      expect(count, 2);
    });
  });

  group('UserInventoryDao Tests', () {
    late User testUser;
    late ShopItem testItem;

    setUp(() async {
      testUser = User(id: 'inv_user', nickname: 'InvUser');
      await userDao.insertUser(testUser);

      testItem = ShopItem(
        id: 'inv_item_1',
        name: 'Test Clothes',
        category: ShopCategory.clothes,
        price: 100,
        currency: Currency.sprout,
      );
      await shopItemDao.insertShopItem(testItem);
    });

    test('Add item to inventory', () async {
      await userInventoryDao.addToInventory(testUser.id, testItem.id);
      final has = await userInventoryDao.hasItem(testUser.id, testItem.id);
      expect(has, true);
    });

    test('Remove item from inventory', () async {
      await userInventoryDao.addToInventory(testUser.id, testItem.id);
      await userInventoryDao.removeFromInventory(testUser.id, testItem.id);

      final has = await userInventoryDao.hasItem(testUser.id, testItem.id);
      expect(has, false);
    });

    test('Get user inventory IDs', () async {
      final item2 = ShopItem(
        id: 'inv_item_2',
        name: 'Clothes 2',
        category: ShopCategory.clothes,
        price: 50,
        currency: Currency.sprout,
      );
      await shopItemDao.insertShopItem(item2);

      await userInventoryDao.addToInventory(testUser.id, testItem.id);
      await userInventoryDao.addToInventory(testUser.id, item2.id);

      final ids = await userInventoryDao.getUserInventoryIds(testUser.id);
      expect(ids.length, 2);
      expect(ids, contains(testItem.id));
      expect(ids, contains(item2.id));
    });

    test('Get user inventory items with JOIN', () async {
      await userInventoryDao.addToInventory(testUser.id, testItem.id);

      final items = await userInventoryDao.getUserInventoryItems(testUser.id);
      expect(items.length, 1);
      expect(items.first.id, testItem.id);
      expect(items.first.name, testItem.name);
    });

    test('Get inventory by category', () async {
      final bgItem = ShopItem(
        id: 'bg_1',
        name: 'Background',
        category: ShopCategory.background,
        price: 200,
        currency: Currency.credit,
      );
      await shopItemDao.insertShopItem(bgItem);

      await userInventoryDao.addToInventory(testUser.id, testItem.id);
      await userInventoryDao.addToInventory(testUser.id, bgItem.id);

      final clothes = await userInventoryDao.getUserInventoryByCategory(
        testUser.id,
        ShopCategory.clothes,
      );
      expect(clothes.length, 1);
      expect(clothes.first.category, ShopCategory.clothes);
    });

    test('Get inventory count', () async {
      await userInventoryDao.addToInventory(testUser.id, testItem.id);

      final count = await userInventoryDao.getInventoryCount(testUser.id);
      expect(count, 1);
    });

    test('Get inventory value by currency', () async {
      final item2 = ShopItem(
        id: 'item_2',
        name: 'Clothes Item 2',
        category: ShopCategory.clothes,
        price: 75,
        currency: Currency.sprout,
      );
      await shopItemDao.insertShopItem(item2);

      await userInventoryDao.addToInventory(testUser.id, testItem.id);
      await userInventoryDao.addToInventory(testUser.id, item2.id);

      final value = await userInventoryDao.getInventoryValue(testUser.id);
      expect(value['sprout'], 175); // 100 + 75
    });

    test('Clear user inventory', () async {
      await userInventoryDao.addToInventory(testUser.id, testItem.id);
      await userInventoryDao.clearUserInventory(testUser.id);

      final count = await userInventoryDao.getInventoryCount(testUser.id);
      expect(count, 0);
    });
  });

  group('ChatMessageDao Tests', () {
    late User testUser;
    late Moong testMoong;

    setUp(() async {
      testUser = User(id: 'chat_user', nickname: 'ChatUser');
      await userDao.insertUser(testUser);

      testMoong = Moong(
        id: 'chat_moong',
        userId: testUser.id,
        name: 'ChatMoong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );
      await moongDao.insertMoong(testMoong);
    });

    test('Insert and retrieve message', () async {
      final message = ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Hello!',
        isUser: true,
        createdAt: DateTime.now(),
      );

      await chatMessageDao.insertMessage(message);
      final messages = await chatMessageDao.getMessagesByMoong(testMoong.id);

      expect(messages.length, 1);
      expect(messages.first.message, 'Hello!');
      expect(messages.first.isUser, true);
    });

    test('Get messages by user', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'User message',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      final messages = await chatMessageDao.getMessagesByUser(testUser.id);
      expect(messages.length, 1);
    });

    test('Get recent messages', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'First',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      await Future.delayed(const Duration(milliseconds: 10));

      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Second',
        isUser: false,
        createdAt: DateTime.now(),
      ));

      final recent = await chatMessageDao.getRecentMessages(testMoong.id, 2);
      expect(recent.length, 2);
      expect(recent.first.message, 'First'); // Oldest first
      expect(recent.last.message, 'Second');
    });

    test('Get message count', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Message 1',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Message 2',
        isUser: false,
        createdAt: DateTime.now(),
      ));

      final count = await chatMessageDao.getMessageCount(testMoong.id);
      expect(count, 2);
    });

    test('Get user vs moong message counts', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'User message',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Moong message',
        isUser: false,
        createdAt: DateTime.now(),
      ));

      final userCount = await chatMessageDao.getUserMessageCount(testMoong.id);
      final moongCount = await chatMessageDao.getMoongMessageCount(testMoong.id);

      expect(userCount, 1);
      expect(moongCount, 1);
    });

    test('Search messages by content', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Hello world',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Goodbye',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      final results = await chatMessageDao.searchMessages(testMoong.id, 'Hello');
      expect(results.length, 1);
      expect(results.first.message, 'Hello world');
    });

    test('Delete messages by moong', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Test',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      await chatMessageDao.deleteMessagesByMoong(testMoong.id);

      final count = await chatMessageDao.getMessageCount(testMoong.id);
      expect(count, 0);
    });

    test('Get conversation statistics', () async {
      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'User 1',
        isUser: true,
        createdAt: DateTime.now(),
      ));

      await chatMessageDao.insertMessage(ChatMessage(
        moongId: testMoong.id,
        userId: testUser.id,
        message: 'Moong 1',
        isUser: false,
        createdAt: DateTime.now(),
      ));

      final stats = await chatMessageDao.getConversationStats(testMoong.id);
      expect(stats['total_messages'], 2);
      expect(stats['user_messages'], 1);
      expect(stats['moong_messages'], 1);
      expect(stats['first_message_time'], isNotNull);
      expect(stats['last_message_time'], isNotNull);
    });
  });
}
