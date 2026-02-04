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
import 'package:moong_flutter/services/seed_data_service.dart';
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
  late UserInventoryDao inventoryDao;
  late ChatMessageDao chatMessageDao;
  late SeedDataService seedDataService;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    userDao = UserDao();
    moongDao = MoongDao();
    questDao = QuestDao();
    shopItemDao = ShopItemDao();
    inventoryDao = UserInventoryDao();
    chatMessageDao = ChatMessageDao();
    seedDataService = SeedDataService();

    // Clean database
    await dbHelper.deleteDb();
  });

  tearDown(() async {
    await dbHelper.deleteDb();
  });

  group('Complete User Journey Integration Test', () {
    test('Full flow: Login → Moong → Quest → Shop → Chat', () async {
      // ===== 1. User Login =====
      print('\n🔐 Step 1: User Login');
      final user = User(
        id: 'user_test_1',
        nickname: 'TestUser',
        level: 1,
        credits: 1000,
        sprouts: 500,
      );
      await userDao.insertUser(user);
      
      final retrievedUser = await userDao.getUser('user_test_1');
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.nickname, 'TestUser');
      print('✅ User logged in: ${retrievedUser.nickname}');

      // ===== 2. Create Moong =====
      print('\n🐾 Step 2: Create Moong');
      final moong = Moong(
        id: 'moong_test_1',
        userId: user.id,
        name: 'MyMoong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );
      await moongDao.insertMoong(moong);
      
      final activeMoong = await moongDao.getActiveMoong(user.id);
      expect(activeMoong, isNotNull);
      expect(activeMoong!.name, 'MyMoong');
      print('✅ Moong created: ${activeMoong.name} (${activeMoong.type})');

      // ===== 3. Create Quest =====
      print('\n🎯 Step 3: Create Quest');
      final quest = Quest(
        id: 'quest_test_1',
        userId: user.id,
        type: QuestType.walk,
        target: 7000,
        progress: 0,
        createdAt: DateTime.now(),
      );
      await questDao.insertQuest(quest);
      
      final activeQuests = await questDao.getActiveQuests(user.id);
      expect(activeQuests.length, 1);
      print('✅ Quest created: ${quest.target}보 목표');

      // Update quest progress
      await questDao.updateQuestProgress(quest.id, 3500);
      final updatedQuest = await questDao.getQuest(quest.id);
      expect(updatedQuest!.progress, 3500);
      print('✅ Quest progress: ${updatedQuest.progress}/${updatedQuest.target}');

      // Complete quest
      await questDao.completeQuest(quest.id);
      final completedQuest = await questDao.getQuest(quest.id);
      expect(completedQuest!.completed, true);
      print('✅ Quest completed!');

      // ===== 4. Seed and Buy Shop Items =====
      print('\n🛍️ Step 4: Shop and Purchase');
      
      // Seed shop items
      await seedDataService.seedShopItems();
      final allItems = await shopItemDao.getAllShopItems();
      expect(allItems.isNotEmpty, true);
      print('✅ Shop items seeded: ${allItems.length} items');

      // Get available items
      final availableItems = await shopItemDao.getAvailableItems(0);
      expect(availableItems.isNotEmpty, true);
      print('✅ Available items: ${availableItems.length}');

      // Purchase an item
      final itemToBuy = allItems.first;
      await inventoryDao.addToInventory(user.id, itemToBuy.id);
      
      final hasItem = await inventoryDao.hasItem(user.id, itemToBuy.id);
      expect(hasItem, true);
      print('✅ Purchased: ${itemToBuy.name} (${itemToBuy.price} ${itemToBuy.currency})');

      // Check inventory
      final inventory = await inventoryDao.getUserInventoryItems(user.id);
      expect(inventory.length, 1);
      print('✅ Inventory count: ${inventory.length}');

      // ===== 5. Chat Messages =====
      print('\n💬 Step 5: Chat with Moong');
      
      // User sends message
      final userMessage = ChatMessage(
        userId: user.id,
        moongId: moong.id,
        message: '안녕 뭉!',
        isUser: true,
      );
      await chatMessageDao.insertMessage(userMessage);
      print('✅ User: ${userMessage.message}');

      // Moong replies
      final moongReply = ChatMessage(
        userId: user.id,
        moongId: moong.id,
        message: '안녕! 오늘 기분이 어때?',
        isUser: false,
      );
      await chatMessageDao.insertMessage(moongReply);
      print('✅ Moong: ${moongReply.message}');

      // Get conversation
      final messages = await chatMessageDao.getMessagesByMoong(moong.id);
      expect(messages.length, 2);
      print('✅ Total messages: ${messages.length}');

      // Get conversation stats
      final stats = await chatMessageDao.getConversationStats(moong.id);
      expect(stats['total_messages'], 2);
      expect(stats['user_messages'], 1);
      expect(stats['moong_messages'], 1);
      print('✅ Chat stats: ${stats['user_messages']} from user, ${stats['moong_messages']} from moong');

      // ===== 6. Update Moong Stats =====
      print('\n📊 Step 6: Update Moong Stats');
      await moongDao.updateMoong(moong.copyWith(
        level: 2,
        intimacy: 100,
      ));
      
      final updatedMoong = await moongDao.getMoong(moong.id);
      expect(updatedMoong!.level, 2);
      expect(updatedMoong.intimacy, 100);
      print('✅ Moong level up! Level: ${updatedMoong.level}, Intimacy: ${updatedMoong.intimacy}');

      // ===== 7. Verify Data Persistence =====
      print('\n💾 Step 7: Verify Data Persistence');
      
      final userCount = await userDao.getAllUsers();
      final moongCount = await moongDao.getMoongsByUserId(user.id);
      final questCount = await questDao.getQuestsByUserId(user.id);
      final messageCount = await chatMessageDao.getMessageCount(moong.id);
      
      expect(userCount.length, 1);
      expect(moongCount.length, 1);
      expect(questCount.length, 1);
      expect(messageCount, 2);
      
      print('✅ Persistence verified:');
      print('   - Users: ${userCount.length}');
      print('   - Moongs: ${moongCount.length}');
      print('   - Quests: ${questCount.length}');
      print('   - Messages: $messageCount');
      print('   - Shop Items: ${allItems.length}');
      print('   - Inventory: ${inventory.length}');

      // ===== 8. Test CASCADE Delete =====
      print('\n🗑️ Step 8: Test CASCADE Delete');
      
      // Delete user should cascade delete all related data
      await userDao.deleteUser(user.id);
      
      final deletedUser = await userDao.getUser(user.id);
      final deletedMoongs = await moongDao.getMoongsByUserId(user.id);
      final deletedQuests = await questDao.getQuestsByUserId(user.id);
      final deletedMessages = await chatMessageDao.getMessagesByUser(user.id);
      
      expect(deletedUser, isNull);
      expect(deletedMoongs.length, 0);
      expect(deletedQuests.length, 0);
      expect(deletedMessages.length, 0);
      
      print('✅ CASCADE delete successful!');
      print('   - User deleted');
      print('   - Moongs deleted');
      print('   - Quests deleted');
      print('   - Messages deleted');

      print('\n🎉 All integration tests passed!');
    });

    test('Multiple users with separate data', () async {
      print('\n👥 Testing Multiple Users');
      
      // Create two users
      final user1 = User(id: 'user1', nickname: 'Alice', credits: 500, sprouts: 300);
      final user2 = User(id: 'user2', nickname: 'Bob', credits: 700, sprouts: 400);
      
      await userDao.insertUser(user1);
      await userDao.insertUser(user2);
      print('✅ Created 2 users');

      // Each user creates a moong
      final moong1 = Moong(
        id: 'moong1',
        userId: user1.id,
        name: 'Alice\'s Moong',
        type: MoongType.pet,
        createdAt: DateTime.now(),
      );
      final moong2 = Moong(
        id: 'moong2',
        userId: user2.id,
        name: 'Bob\'s Moong',
        type: MoongType.guide,
        createdAt: DateTime.now(),
      );
      
      await moongDao.insertMoong(moong1);
      await moongDao.insertMoong(moong2);
      print('✅ Each user has their own Moong');

      // Verify isolation
      final aliceMoongs = await moongDao.getMoongsByUserId(user1.id);
      final bobMoongs = await moongDao.getMoongsByUserId(user2.id);
      
      expect(aliceMoongs.length, 1);
      expect(bobMoongs.length, 1);
      expect(aliceMoongs.first.name, 'Alice\'s Moong');
      expect(bobMoongs.first.name, 'Bob\'s Moong');
      
      print('✅ Data isolation verified');
      print('   - Alice has: ${aliceMoongs.first.name}');
      print('   - Bob has: ${bobMoongs.first.name}');
    });
  });
}
