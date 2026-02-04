import 'package:flutter_test/flutter_test.dart';
import 'package:moong_flutter/services/database_helper.dart';
import 'package:moong_flutter/database/user_dao.dart';
import 'package:moong_flutter/database/moong_dao.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/models/moong.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite_ffi for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;
  late UserDao userDao;
  late MoongDao moongDao;

  setUp(() async {
    // Initialize database and DAOs before each test
    dbHelper = DatabaseHelper.instance;
    userDao = UserDao();
    moongDao = MoongDao();

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
}
