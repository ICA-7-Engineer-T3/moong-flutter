import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:moong_flutter/providers/moong_provider.dart';
import 'package:moong_flutter/models/moong.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/database/moong_dao.dart';
import 'package:moong_flutter/database/user_dao.dart';
import 'package:moong_flutter/services/database_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Initialize database for all tests
  setUpAll(() {
    initTestDatabase();
  });

  group('MoongProvider Tests', () {
    late MoongProvider provider;
    late String testUserId;
    int listenerCallCount = 0;

    setUp(() async {
      // Create fresh database for each test
      await createFreshDatabase();

      // Create a test user first (required for foreign key constraint)
      testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      if (!kIsWeb) {
        final userDao = UserDao();
        final testUser = User(
          id: testUserId,
          nickname: 'TestUser',
        );
        await userDao.insertUser(testUser);
      }

      // Create provider
      provider = MoongProvider();
      listenerCallCount = 0;

      // Add listener to track notifyListeners calls
      provider.addListener(() {
        listenerCallCount++;
      });
    });

    tearDown(() async {
      provider.dispose();
      // Clean up database
      await DatabaseHelper.instance.deleteDb();
    });

    group('Initial State', () {
      test('should have empty moongs list initially', () {
        expect(provider.moongs, isEmpty);
      });

      test('should not have moong initially', () {
        expect(provider.hasMoong, isFalse);
      });

      test('should not have active moong initially', () {
        expect(provider.activeMoong, isNull);
        expect(provider.hasActiveMoong, isFalse);
      });

      test('should not be loading initially', () {
        expect(provider.isLoading, isFalse);
      });
    });

    group('Initialize', () {
      test('should load moongs for user', () async {
        // Arrange - create some moongs first
        await provider.createMoong(testUserId, 'TestMoong', MoongType.pet);

        // Create new provider to test initialization
        final newProvider = MoongProvider();
        await newProvider.initialize(testUserId);

        // Assert
        if (!kIsWeb) {
          expect(newProvider.moongs, isNotEmpty);
          expect(newProvider.hasMoong, isTrue);
        }

        newProvider.dispose();
      });

      test('should set loading state during initialization', () async {
        // Arrange
        bool wasLoadingDuringInit = false;
        provider.addListener(() {
          if (provider.isLoading) {
            wasLoadingDuringInit = true;
          }
        });

        // Act
        await provider.initialize(testUserId);

        // Assert
        if (!kIsWeb) {
          expect(wasLoadingDuringInit, isTrue);
        }
        expect(provider.isLoading, isFalse);
      });

      test('should handle empty moongs list', () async {
        // Act
        await provider.initialize(testUserId);

        // Assert
        expect(provider.moongs, isEmpty);
        expect(provider.activeMoong, isNull);
      });
    });

    group('Create Moong', () {
      test('should create moong successfully', () async {
        // Act
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Assert
        expect(provider.moongs, hasLength(1));
        expect(provider.moongs.first.name, equals('MyMoong'));
        expect(provider.moongs.first.type, equals(MoongType.pet));
        expect(provider.moongs.first.userId, equals(testUserId));
      });

      test('should set first moong as active moong', () async {
        // Act
        await provider.createMoong(testUserId, 'FirstMoong', MoongType.pet);

        // Assert
        expect(provider.activeMoong, isNotNull);
        expect(provider.activeMoong!.name, equals('FirstMoong'));
        expect(provider.hasActiveMoong, isTrue);
      });

      test('should not change active moong when creating additional moongs', () async {
        // Arrange
        await provider.createMoong(testUserId, 'FirstMoong', MoongType.pet);
        final firstActiveMoong = provider.activeMoong;

        // Act
        await provider.createMoong(testUserId, 'SecondMoong', MoongType.mate);

        // Assert
        expect(provider.moongs, hasLength(2));
        expect(provider.activeMoong, equals(firstActiveMoong));
      });

      test('should notify listeners when creating moong', () async {
        // Arrange
        listenerCallCount = 0;

        // Act
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should persist moong to database on non-web platform', () async {
        // Act
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Assert
        if (!kIsWeb) {
          final dao = MoongDao();
          final moongs = await dao.getMoongsByUserId(testUserId);
          expect(moongs, hasLength(1));
          expect(moongs.first.name, equals('MyMoong'));
        }
      });

      test('should create moongs with all three types', () async {
        // Act
        await provider.createMoong(testUserId, 'Pet', MoongType.pet);
        await provider.createMoong(testUserId, 'Mate', MoongType.mate);
        await provider.createMoong(testUserId, 'Guide', MoongType.guide);

        // Assert
        expect(provider.moongs, hasLength(3));
        expect(provider.moongs.map((m) => m.type).toSet(),
               equals({MoongType.pet, MoongType.mate, MoongType.guide}));
      });

      test('should create moongs with default values', () async {
        // Act
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Assert
        final moong = provider.moongs.first;
        expect(moong.level, equals(1));
        expect(moong.intimacy, equals(0));
        expect(moong.isActive, isTrue);
        expect(moong.graduatedAt, isNull);
      });

      test('should add new moongs at the beginning of list', () async {
        // Act
        await provider.createMoong(testUserId, 'First', MoongType.pet);
        await provider.createMoong(testUserId, 'Second', MoongType.mate);
        await provider.createMoong(testUserId, 'Third', MoongType.guide);

        // Assert - newest should be first
        expect(provider.moongs[0].name, equals('Third'));
        expect(provider.moongs[1].name, equals('Second'));
        expect(provider.moongs[2].name, equals('First'));
      });
    });

    group('Set Active Moong', () {
      test('should set active moong successfully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'First', MoongType.pet);
        await provider.createMoong(testUserId, 'Second', MoongType.mate);
        final secondMoongId = provider.moongs[0].id; // Second is at index 0

        // Act
        await provider.setActiveMoong(secondMoongId);

        // Assert
        expect(provider.activeMoong!.name, equals('Second'));
      });

      test('should notify listeners when changing active moong', () async {
        // Arrange
        await provider.createMoong(testUserId, 'First', MoongType.pet);
        await provider.createMoong(testUserId, 'Second', MoongType.mate);
        final secondMoongId = provider.moongs[0].id;
        listenerCallCount = 0;

        // Act
        await provider.setActiveMoong(secondMoongId);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should handle non-existent moong ID gracefully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final originalActive = provider.activeMoong;

        // Act
        await provider.setActiveMoong('non_existent_id');

        // Assert - should not change active moong
        expect(provider.activeMoong, equals(originalActive));
      });
    });

    group('Update Moong Level', () {
      test('should update moong level successfully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.updateMoongLevel(moongId, 5);

        // Assert
        expect(provider.moongs.first.level, equals(5));
      });

      test('should maintain immutability when updating level', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final originalMoong = provider.moongs.first;
        final originalList = provider.moongs;
        final moongId = originalMoong.id;

        // Act
        await provider.updateMoongLevel(moongId, 5);

        // Assert - should create new objects
        expect(provider.moongs.first, isNot(same(originalMoong)));
        expect(provider.moongs, isNot(same(originalList)));
      });

      test('should update active moong if it is the updated moong', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.activeMoong!.id;

        // Act
        await provider.updateMoongLevel(moongId, 5);

        // Assert
        expect(provider.activeMoong!.level, equals(5));
      });

      test('should not update active moong if different moong updated', () async {
        // Arrange
        await provider.createMoong(testUserId, 'First', MoongType.pet);
        await Future.delayed(const Duration(milliseconds: 10)); // Ensure different timestamps
        await provider.createMoong(testUserId, 'Second', MoongType.mate);

        // Verify we have 2 different moongs
        expect(provider.moongs, hasLength(2));
        final secondMoongId = provider.moongs[0].id;
        final firstMoongId = provider.moongs[1].id;
        expect(secondMoongId, isNot(equals(firstMoongId)));

        // Explicitly set Second as active
        await provider.setActiveMoong(secondMoongId);
        expect(provider.activeMoong!.name, equals('Second'));
        final originalActiveLevel = provider.activeMoong!.level;

        // Update First moong (which is NOT active)
        await provider.updateMoongLevel(firstMoongId, 10);

        // Assert - active moong (Second) level unchanged, First level changed
        expect(provider.activeMoong!.name, equals('Second'));
        expect(provider.activeMoong!.level, equals(originalActiveLevel));
        expect(provider.moongs[1].level, equals(10)); // First moong's level changed
      });

      test('should notify listeners when updating level', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;
        listenerCallCount = 0;

        // Act
        await provider.updateMoongLevel(moongId, 5);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should persist level update to database on non-web platform', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.updateMoongLevel(moongId, 10);

        // Assert
        if (!kIsWeb) {
          final dao = MoongDao();
          final moongs = await dao.getMoongsByUserId(testUserId);
          expect(moongs.first.level, equals(10));
        }
      });

      test('should handle updating non-existent moong gracefully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Act - no throw expected
        await provider.updateMoongLevel('non_existent_id', 5);

        // Assert - original moong unchanged
        expect(provider.moongs.first.level, equals(1));
      });
    });

    group('Update Moong Intimacy', () {
      test('should update moong intimacy successfully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.updateMoongIntimacy(moongId, 50);

        // Assert
        expect(provider.moongs.first.intimacy, equals(50));
      });

      test('should maintain immutability when updating intimacy', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final originalMoong = provider.moongs.first;
        final originalList = provider.moongs;
        final moongId = originalMoong.id;

        // Act
        await provider.updateMoongIntimacy(moongId, 50);

        // Assert
        expect(provider.moongs.first, isNot(same(originalMoong)));
        expect(provider.moongs, isNot(same(originalList)));
      });

      test('should update active moong intimacy if it is the updated moong', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.activeMoong!.id;

        // Act
        await provider.updateMoongIntimacy(moongId, 75);

        // Assert
        expect(provider.activeMoong!.intimacy, equals(75));
      });

      test('should notify listeners when updating intimacy', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;
        listenerCallCount = 0;

        // Act
        await provider.updateMoongIntimacy(moongId, 50);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should handle updating non-existent moong gracefully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Act
        await provider.updateMoongIntimacy('non_existent_id', 50);

        // Assert - original moong unchanged
        expect(provider.moongs.first.intimacy, equals(0));
      });
    });

    group('Graduate Moong', () {
      test('should graduate moong successfully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.graduateMoong(moongId);

        // Assert
        final graduatedMoong = provider.moongs.first;
        expect(graduatedMoong.isActive, isFalse);
        expect(graduatedMoong.graduatedAt, isNotNull);
      });

      test('should maintain immutability when graduating moong', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final originalMoong = provider.moongs.first;
        final originalList = provider.moongs;
        final moongId = originalMoong.id;

        // Act
        await provider.graduateMoong(moongId);

        // Assert
        expect(provider.moongs.first, isNot(same(originalMoong)));
        expect(provider.moongs, isNot(same(originalList)));
      });

      test('should switch to another active moong when graduating current active', () async {
        // Arrange
        await provider.createMoong(testUserId, 'First', MoongType.pet);
        await provider.createMoong(testUserId, 'Second', MoongType.mate);
        final secondMoongId = provider.moongs[0].id;
        await provider.setActiveMoong(secondMoongId);

        // Act - graduate the active moong (Second)
        await provider.graduateMoong(secondMoongId);

        // Assert - should switch to another moong (not necessarily First due to fallback logic)
        expect(provider.activeMoong, isNotNull);
        // The graduated moong should not be active anymore
        expect(provider.moongs.firstWhere((m) => m.id == secondMoongId).isActive, isFalse);
      });

      test('should notify listeners when graduating moong', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;
        listenerCallCount = 0;

        // Act
        await provider.graduateMoong(moongId);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should persist graduation to database on non-web platform', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.graduateMoong(moongId);

        // Assert
        if (!kIsWeb) {
          final dao = MoongDao();
          final moongs = await dao.getMoongsByUserId(testUserId);
          expect(moongs.first.isActive, isFalse);
          expect(moongs.first.graduatedAt, isNotNull);
        }
      });

      test('should handle graduating non-existent moong gracefully', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);

        // Act
        await provider.graduateMoong('non_existent_id');

        // Assert - moong unchanged
        expect(provider.moongs.first.isActive, isTrue);
        expect(provider.moongs.first.graduatedAt, isNull);
      });

      test('should fallback to first moong when no other active moongs', () async {
        // Arrange - create single moong
        await provider.createMoong(testUserId, 'OnlyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.graduateMoong(moongId);

        // Assert - should fallback to first moong (even though inactive)
        expect(provider.activeMoong, isNotNull);
        expect(provider.activeMoong!.name, equals('OnlyMoong'));
      });
    });

    group('Edge Cases', () {
      test('should handle multiple sequential updates correctly', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act
        await provider.updateMoongLevel(moongId, 5);
        await provider.updateMoongIntimacy(moongId, 50);

        // Assert
        expect(provider.moongs.first.level, equals(5));
        expect(provider.moongs.first.intimacy, equals(50));
      });

      test('should preserve other moong properties when updating', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;
        final originalName = provider.moongs.first.name;
        final originalType = provider.moongs.first.type;

        // Act
        await provider.updateMoongLevel(moongId, 10);

        // Assert - only level changed
        expect(provider.moongs.first.name, equals(originalName));
        expect(provider.moongs.first.type, equals(originalType));
        expect(provider.moongs.first.level, equals(10));
      });

      test('should handle updating same value', () async {
        // Arrange
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        final moongId = provider.moongs.first.id;

        // Act - update to same level
        await provider.updateMoongLevel(moongId, 1);

        // Assert - should still create new object (immutability)
        expect(provider.moongs.first.level, equals(1));
      });
    });

    group('State Management', () {
      test('hasMoong should reflect moongs list state', () async {
        // Initially empty
        expect(provider.hasMoong, isFalse);

        // After creating moong
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        expect(provider.hasMoong, isTrue);
      });

      test('hasActiveMoong should reflect activeMoong state', () async {
        // Initially no active moong
        expect(provider.hasActiveMoong, isFalse);

        // After creating moong
        await provider.createMoong(testUserId, 'MyMoong', MoongType.pet);
        expect(provider.hasActiveMoong, isTrue);
      });

      test('should maintain list order across operations', () async {
        // Arrange
        await provider.createMoong(testUserId, 'First', MoongType.pet);
        await provider.createMoong(testUserId, 'Second', MoongType.mate);
        await provider.createMoong(testUserId, 'Third', MoongType.guide);

        // Act - update middle moong
        final secondMoongId = provider.moongs[1].id;
        await provider.updateMoongLevel(secondMoongId, 10);

        // Assert - order preserved
        expect(provider.moongs[0].name, equals('Third'));
        expect(provider.moongs[1].name, equals('Second'));
        expect(provider.moongs[2].name, equals('First'));
      });
    });
  });
}
