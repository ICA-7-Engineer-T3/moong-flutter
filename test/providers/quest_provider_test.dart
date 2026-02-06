import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:moong_flutter/providers/quest_provider.dart';
import 'package:moong_flutter/models/quest.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/models/moong.dart';
import 'package:moong_flutter/database/quest_dao.dart';
import 'package:moong_flutter/database/user_dao.dart';
import 'package:moong_flutter/database/moong_dao.dart';
import 'package:moong_flutter/services/database_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Initialize database for all tests
  setUpAll(() {
    initTestDatabase();
  });

  group('QuestProvider Tests', () {
    late QuestProvider provider;
    late String testUserId;
    late String testMoongId;
    int listenerCallCount = 0;

    setUp(() async {
      // Create fresh database for each test
      await createFreshDatabase();

      // Create test user and moong (required for foreign keys)
      testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      testMoongId = 'test_moong_${DateTime.now().millisecondsSinceEpoch}';

      if (!kIsWeb) {
        final userDao = UserDao();
        final moongDao = MoongDao();

        final testUser = User(id: testUserId, nickname: 'TestUser');
        await userDao.insertUser(testUser);

        final testMoong = Moong(
          id: testMoongId,
          userId: testUserId,
          name: 'TestMoong',
          type: MoongType.pet,
          createdAt: DateTime.now(),
        );
        await moongDao.insertMoong(testMoong);
      }

      // Create provider
      provider = QuestProvider();
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
      test('should have empty quests list initially', () {
        expect(provider.quests, isEmpty);
      });

      test('should not be loading initially', () {
        expect(provider.isLoading, isFalse);
      });

      test('should have empty active quests initially', () {
        expect(provider.activeQuests, isEmpty);
      });

      test('should have empty completed quests initially', () {
        expect(provider.completedQuests, isEmpty);
      });
    });

    group('Initialize', () {
      test('should initialize with userId and load quests', () async {
        // Act
        await provider.initialize(testUserId);

        // Assert - should not throw error
        expect(provider.quests, isEmpty); // No quests created yet
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
    });

    group('Create Daily Quests', () {
      test('should create 3 daily quests with correct targets', () async {
        // Act
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests, hasLength(3));
          expect(provider.quests.map((q) => q.target).toSet(),
                 equals({3000, 7000, 10000}));
        }
      });

      test('should create quests with walk type', () async {
        // Act
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.every((q) => q.type == QuestType.walk), isTrue);
        }
      });

      test('should create quests with zero progress', () async {
        // Act
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.every((q) => q.progress == 0), isTrue);
        }
      });

      test('should create quests as not completed', () async {
        // Act
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.every((q) => !q.completed), isTrue);
        }
      });

      test('should persist quests to database', () async {
        // Act
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          final dao = QuestDao();
          final quests = await dao.getQuestsByUserId(testUserId);
          expect(quests, hasLength(3));
        }
      });

      test('should associate quests with moongId if provided', () async {
        // Act
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.every((q) => q.moongId == testMoongId), isTrue);
        }
      });

      test('should create quests with null moongId if not provided', () async {
        // Act
        await provider.createDailyQuests(testUserId, null);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.every((q) => q.moongId == null), isTrue);
        }
      });
    });

    group('Load Quests', () {
      test('should load quests for user', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);

        // Create new provider to test loading
        final newProvider = QuestProvider();
        await newProvider.initialize(testUserId);

        // Assert
        if (!kIsWeb) {
          expect(newProvider.quests, hasLength(3));
        }

        newProvider.dispose();
      });

      test('should not load quests if userId is null', () async {
        // Act
        await provider.loadQuests();

        // Assert
        expect(provider.quests, isEmpty);
      });
    });

    group('Update Progress', () {
      test('should update quest progress successfully', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;

        // Act
        await provider.updateProgress(questId, 1500);

        // Assert
        if (!kIsWeb) {
          final updatedQuest = provider.quests.firstWhere((q) => q.id == questId);
          expect(updatedQuest.progress, equals(1500));
        }
      });

      test('should maintain immutability when updating progress', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final originalQuest = provider.quests.first;
        final originalList = provider.quests;
        final questId = originalQuest.id;

        // Act
        await provider.updateProgress(questId, 1500);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.first, isNot(same(originalQuest)));
          expect(provider.quests, isNot(same(originalList)));
        }
      });

      test('should notify listeners when updating progress', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;
        listenerCallCount = 0;

        // Act
        await provider.updateProgress(questId, 1500);

        // Assert
        if (!kIsWeb) {
          expect(listenerCallCount, equals(1));
        }
      });

      test('should persist progress to database', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;

        // Act
        await provider.updateProgress(questId, 2500);

        // Assert
        if (!kIsWeb) {
          final dao = QuestDao();
          final quests = await dao.getQuestsByUserId(testUserId);
          final updatedQuest = quests.firstWhere((q) => q.id == questId);
          expect(updatedQuest.progress, equals(2500));
        }
      });

      test('should handle updating non-existent quest gracefully', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);

        // Act - should not throw
        await provider.updateProgress('non_existent_id', 1000);

        // Assert - quests unchanged
        if (!kIsWeb) {
          expect(provider.quests.every((q) => q.progress == 0), isTrue);
        }
      });
    });

    group('Complete Quest', () {
      test('should complete quest successfully', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;

        // Act
        await provider.completeQuest(questId);

        // Assert
        if (!kIsWeb) {
          final completedQuest = provider.quests.firstWhere((q) => q.id == questId);
          expect(completedQuest.completed, isTrue);
          expect(completedQuest.completedAt, isNotNull);
        }
      });

      test('should maintain immutability when completing quest', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final originalQuest = provider.quests.first;
        final originalList = provider.quests;
        final questId = originalQuest.id;

        // Act
        await provider.completeQuest(questId);

        // Assert
        if (!kIsWeb) {
          expect(provider.quests.first, isNot(same(originalQuest)));
          expect(provider.quests, isNot(same(originalList)));
        }
      });

      test('should notify listeners when completing quest', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;
        listenerCallCount = 0;

        // Act
        await provider.completeQuest(questId);

        // Assert
        if (!kIsWeb) {
          expect(listenerCallCount, equals(1));
        }
      });

      test('should call onSproutsEarned callback with correct reward', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id; // target 3000
        int? earnedSprouts;

        // Act
        await provider.completeQuest(
          questId,
          onSproutsEarned: (sprouts) {
            earnedSprouts = sprouts;
          },
        );

        // Assert
        if (!kIsWeb) {
          expect(earnedSprouts, equals(30)); // 3000 / 1000 * 10 = 30
        }
      });

      test('should call onIntimacyEarned callback with correct values', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id; // target 3000
        String? receivedMoongId;
        int? intimacyIncrease;

        // Act
        await provider.completeQuest(
          questId,
          onIntimacyEarned: (moongId, increase) {
            receivedMoongId = moongId;
            intimacyIncrease = increase;
          },
        );

        // Assert
        if (!kIsWeb) {
          expect(receivedMoongId, equals(testMoongId));
          expect(intimacyIncrease, equals(3)); // 3000 / 1000 = 3
        }
      });

      test('should calculate rewards correctly for different targets', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final quest7000 = provider.quests.firstWhere((q) => q.target == 7000);
        int? earnedSprouts;

        // Act
        await provider.completeQuest(
          quest7000.id,
          onSproutsEarned: (sprouts) {
            earnedSprouts = sprouts;
          },
        );

        // Assert
        if (!kIsWeb) {
          expect(earnedSprouts, equals(70)); // 7000 / 1000 * 10 = 70
        }
      });

      test('should not call onIntimacyEarned if moongId is null', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, null);
        final questId = provider.quests.first.id;
        bool callbackCalled = false;

        // Act
        await provider.completeQuest(
          questId,
          onIntimacyEarned: (moongId, increase) {
            callbackCalled = true;
          },
        );

        // Assert
        expect(callbackCalled, isFalse);
      });

      test('should persist completion to database', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;

        // Act
        await provider.completeQuest(questId);

        // Assert
        if (!kIsWeb) {
          final dao = QuestDao();
          final quests = await dao.getQuestsByUserId(testUserId);
          final completedQuest = quests.firstWhere((q) => q.id == questId);
          expect(completedQuest.completed, isTrue);
        }
      });
    });

    group('Active and Completed Quests', () {
      test('should filter active quests correctly', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final firstQuestId = provider.quests.first.id;
        await provider.completeQuest(firstQuestId);

        // Assert
        if (!kIsWeb) {
          expect(provider.activeQuests, hasLength(2));
          expect(provider.activeQuests.every((q) => !q.completed), isTrue);
        }
      });

      test('should filter completed quests correctly', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final firstQuestId = provider.quests.first.id;
        await provider.completeQuest(firstQuestId);

        // Assert
        if (!kIsWeb) {
          expect(provider.completedQuests, hasLength(1));
          expect(provider.completedQuests.every((q) => q.completed), isTrue);
        }
      });

      test('should return all active quests when none completed', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);

        // Assert
        if (!kIsWeb) {
          expect(provider.activeQuests, hasLength(3));
          expect(provider.completedQuests, isEmpty);
        }
      });

      test('should return all completed quests when all completed', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        for (final quest in provider.quests) {
          await provider.completeQuest(quest.id);
        }

        // Assert
        if (!kIsWeb) {
          expect(provider.activeQuests, isEmpty);
          expect(provider.completedQuests, hasLength(3));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle multiple progress updates correctly', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;

        // Act
        await provider.updateProgress(questId, 1000);
        await provider.updateProgress(questId, 2000);
        await provider.updateProgress(questId, 2500);

        // Assert
        if (!kIsWeb) {
          final quest = provider.quests.firstWhere((q) => q.id == questId);
          expect(quest.progress, equals(2500));
        }
      });

      test('should preserve quest properties when updating progress', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final originalQuest = provider.quests.first;
        final questId = originalQuest.id;

        // Act
        await provider.updateProgress(questId, 1500);

        // Assert
        if (!kIsWeb) {
          final updatedQuest = provider.quests.firstWhere((q) => q.id == questId);
          expect(updatedQuest.id, equals(originalQuest.id));
          expect(updatedQuest.target, equals(originalQuest.target));
          expect(updatedQuest.type, equals(originalQuest.type));
          expect(updatedQuest.completed, equals(originalQuest.completed));
        }
      });

      test('should handle completing already completed quest', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final questId = provider.quests.first.id;
        await provider.completeQuest(questId);
        final firstCompletedAt = provider.quests.first.completedAt;

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        // Act - complete again
        await provider.completeQuest(questId);

        // Assert
        if (!kIsWeb) {
          final quest = provider.quests.firstWhere((q) => q.id == questId);
          expect(quest.completed, isTrue);
          // CompletedAt should be updated
          expect(quest.completedAt, isNot(equals(firstCompletedAt)));
        }
      });
    });

    group('State Management', () {
      test('should maintain quest list order', () async {
        // Arrange
        await provider.createDailyQuests(testUserId, testMoongId);
        final originalOrder = provider.quests.map((q) => q.id).toList();

        // Act - update progress on middle quest
        final middleQuestId = provider.quests[1].id;
        await provider.updateProgress(middleQuestId, 1000);

        // Assert - order preserved
        if (!kIsWeb) {
          final newOrder = provider.quests.map((q) => q.id).toList();
          expect(newOrder, equals(originalOrder));
        }
      });

      test('should handle empty quest list operations gracefully', () {
        // Act & Assert - should not throw
        expect(provider.activeQuests, isEmpty);
        expect(provider.completedQuests, isEmpty);
      });
    });
  });
}
