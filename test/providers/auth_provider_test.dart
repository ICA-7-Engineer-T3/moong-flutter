import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:moong_flutter/providers/auth_provider.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/database/user_dao.dart';
import 'package:moong_flutter/services/database_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Initialize database for all tests
  setUpAll(() {
    initTestDatabase();
  });

  group('AuthProvider Tests', () {
    late AuthProvider provider;
    int listenerCallCount = 0;

    setUp(() async {
      // Create fresh database for each test
      await createFreshDatabase();

      // Create provider after database is ready
      provider = AuthProvider();
      listenerCallCount = 0;

      // Add listener to track notifyListeners calls
      provider.addListener(() {
        listenerCallCount++;
      });

      // Wait a bit for constructor's _loadUser to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      provider.dispose();
      // Clean up database
      await DatabaseHelper.instance.deleteDb();
    });

    group('Initial State', () {
      test('should have null currentUser initially', () {
        expect(provider.currentUser, isNull);
      });

      test('should not be authenticated initially', () {
        expect(provider.isAuthenticated, isFalse);
      });

      test('should not be loading initially (web platform)', () {
        expect(provider.isLoading, isFalse);
      });
    });

    group('Login', () {
      test('should login successfully and create user', () async {
        // Act
        final result = await provider.login('TestUser', 'password123');

        // Assert
        expect(result, isTrue);
        expect(provider.currentUser, isNotNull);
        expect(provider.currentUser!.nickname, equals('TestUser'));
        expect(provider.isAuthenticated, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('should persist user to database on non-web platform', () async {
        // Act
        await provider.login('TestUser', 'password123');

        // Assert - user should persist if not on web
        if (!kIsWeb) {
          final dao = UserDao();
          final persistedUser = await dao.getCurrentUser();
          expect(persistedUser, isNotNull);
          expect(persistedUser!.nickname, equals('TestUser'));
        }
      });

      test('should set loading state during login', () async {
        // Arrange
        bool wasLoadingDuringLogin = false;
        provider.addListener(() {
          if (provider.isLoading) {
            wasLoadingDuringLogin = true;
          }
        });

        // Act
        await provider.login('TestUser', 'password123');

        // Assert
        expect(wasLoadingDuringLogin, isTrue);
        expect(provider.isLoading, isFalse); // Should be false after completion
      });

      test('should notify listeners during login process', () async {
        // Reset counter
        listenerCallCount = 0;

        // Act
        await provider.login('TestUser', 'password123');

        // Assert - should notify at least twice (start loading, finish loading)
        expect(listenerCallCount, greaterThanOrEqualTo(2));
      });

      test('should always return true for current login implementation', () async {
        // Note: Current implementation always returns true
        // Future: Add actual authentication logic with failure cases

        // Act
        final result = await provider.login('TestUser', 'password123');

        // Assert
        expect(result, isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('should create user with unique ID based on timestamp', () async {
        // Act
        await provider.login('User1', 'pass1');
        final user1Id = provider.currentUser!.id;

        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        await provider.login('User2', 'pass2');
        final user2Id = provider.currentUser!.id;

        // Assert
        expect(user1Id, isNot(equals(user2Id)));
      });
    });

    group('Logout', () {
      test('should logout and clear current user', () async {
        // Arrange - login first
        await provider.login('TestUser', 'password123');
        expect(provider.isAuthenticated, isTrue);

        // Act
        await provider.logout();

        // Assert
        expect(provider.currentUser, isNull);
        expect(provider.isAuthenticated, isFalse);
      });

      test('should notify listeners on logout', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        listenerCallCount = 0;

        // Act
        await provider.logout();

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should handle logout when not authenticated', () async {
        // Act - logout without login
        await provider.logout();

        // Assert - should not throw error
        expect(provider.currentUser, isNull);
        expect(provider.isAuthenticated, isFalse);
      });
    });

    group('Update Credits', () {
      test('should update credits when user is authenticated', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final originalCredits = provider.currentUser!.credits;

        // Act
        await provider.updateCredits(500);

        // Assert
        expect(provider.currentUser!.credits, equals(500));
        expect(provider.currentUser!.credits, isNot(equals(originalCredits)));
      });

      test('should maintain immutability when updating credits', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final originalUser = provider.currentUser;

        // Act
        await provider.updateCredits(500);

        // Assert - should be a different object (immutability)
        expect(provider.currentUser, isNot(same(originalUser)));
        expect(provider.currentUser!.nickname, equals(originalUser!.nickname));
        expect(provider.currentUser!.id, equals(originalUser.id));
      });

      test('should notify listeners when credits updated', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        listenerCallCount = 0;

        // Act
        await provider.updateCredits(500);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should not update credits when user is null', () async {
        // Act
        await provider.updateCredits(500);

        // Assert - should not throw error
        expect(provider.currentUser, isNull);
      });

      test('should persist credits to database on non-web platform', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final userId = provider.currentUser!.id;

        // Act
        await provider.updateCredits(500);

        // Assert - verify database persistence if not on web
        if (!kIsWeb) {
          final dao = UserDao();
          final persistedUser = await dao.getUser(userId);
          expect(persistedUser, isNotNull);
          expect(persistedUser!.credits, equals(500));
        }
      });
    });

    group('Update Sprouts', () {
      test('should update sprouts when user is authenticated', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final originalSprouts = provider.currentUser!.sprouts;

        // Act
        await provider.updateSprouts(1000);

        // Assert
        expect(provider.currentUser!.sprouts, equals(1000));
        expect(provider.currentUser!.sprouts, isNot(equals(originalSprouts)));
      });

      test('should maintain immutability when updating sprouts', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final originalUser = provider.currentUser;

        // Act
        await provider.updateSprouts(1000);

        // Assert
        expect(provider.currentUser, isNot(same(originalUser)));
      });

      test('should notify listeners when sprouts updated', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        listenerCallCount = 0;

        // Act
        await provider.updateSprouts(1000);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should not update sprouts when user is null', () async {
        // Act
        await provider.updateSprouts(1000);

        // Assert
        expect(provider.currentUser, isNull);
      });
    });

    group('Update Level', () {
      test('should update level when user is authenticated', () async {
        // Arrange
        await provider.login('TestUser', 'password123');

        // Act
        await provider.updateLevel(5);

        // Assert
        expect(provider.currentUser!.level, equals(5));
      });

      test('should maintain immutability when updating level', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final originalUser = provider.currentUser;

        // Act
        await provider.updateLevel(5);

        // Assert
        expect(provider.currentUser, isNot(same(originalUser)));
      });

      test('should notify listeners when level updated', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        listenerCallCount = 0;

        // Act
        await provider.updateLevel(5);

        // Assert
        expect(listenerCallCount, equals(1));
      });

      test('should not update level when user is null', () async {
        // Act
        await provider.updateLevel(5);

        // Assert
        expect(provider.currentUser, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple sequential updates correctly', () async {
        // Arrange
        await provider.login('TestUser', 'password123');

        // Act
        await provider.updateCredits(100);
        await provider.updateSprouts(200);
        await provider.updateLevel(3);

        // Assert
        expect(provider.currentUser!.credits, equals(100));
        expect(provider.currentUser!.sprouts, equals(200));
        expect(provider.currentUser!.level, equals(3));
      });

      test('should handle updating with same values', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        final initialCredits = provider.currentUser!.credits;

        // Act
        await provider.updateCredits(initialCredits);

        // Assert - should still create new object (immutability)
        expect(provider.currentUser!.credits, equals(initialCredits));
      });

      test('should handle zero and negative values for credits', () async {
        // Arrange
        await provider.login('TestUser', 'password123');

        // Act & Assert - zero
        await provider.updateCredits(0);
        expect(provider.currentUser!.credits, equals(0));

        // Act & Assert - negative (application should validate, but provider allows it)
        await provider.updateCredits(-100);
        expect(provider.currentUser!.credits, equals(-100));
      });

      test('should preserve other fields when updating credits', () async {
        // Arrange
        await provider.login('TestUser', 'password123');
        await provider.updateLevel(5);
        await provider.updateSprouts(500);
        final originalNickname = provider.currentUser!.nickname;
        final originalLevel = provider.currentUser!.level;
        final originalSprouts = provider.currentUser!.sprouts;

        // Act
        await provider.updateCredits(1000);

        // Assert - only credits changed
        expect(provider.currentUser!.nickname, equals(originalNickname));
        expect(provider.currentUser!.level, equals(originalLevel));
        expect(provider.currentUser!.sprouts, equals(originalSprouts));
        expect(provider.currentUser!.credits, equals(1000));
      });
    });

    group('State Management', () {
      test('isAuthenticated should reflect currentUser state', () async {
        // Initially not authenticated
        expect(provider.isAuthenticated, isFalse);

        // After login
        await provider.login('TestUser', 'password123');
        expect(provider.isAuthenticated, isTrue);

        // After logout
        await provider.logout();
        expect(provider.isAuthenticated, isFalse);
      });

      test('should handle rapid login/logout cycles', () async {
        // Act
        await provider.login('User1', 'pass1');
        await provider.logout();
        await provider.login('User2', 'pass2');
        await provider.logout();
        await provider.login('User3', 'pass3');

        // Assert
        expect(provider.isAuthenticated, isTrue);
        expect(provider.currentUser!.nickname, equals('User3'));
      });
    });
  });
}
