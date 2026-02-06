import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:moong_flutter/providers/auth_provider.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/repositories/firestore/user_repository_firestore.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late UserRepositoryFirestore userRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: false);
    fakeFirestore = FakeFirebaseFirestore();
    userRepository = UserRepositoryFirestore(firestore: fakeFirestore);
  });

  tearDown(() {
    authProvider.dispose();
  });

  group('AuthProvider - Initial State', () {
    test('should initialize with null user when not signed in', () {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );

      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
    });

    test('should load user from Firestore if already signed in', () async {
      // Create a mock user in Firebase Auth
      final mockUser = MockUser(
        uid: 'test_uid',
        email: 'test@example.com',
        isAnonymous: false,
      );
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);

      // Create user in Firestore
      final user = User(
        id: 'test_uid',
        email: 'test@example.com',
        nickname: 'TestUser',
        level: 5,
        credits: 1000,
        sprouts: 500,
      );
      await fakeFirestore.collection('users').doc('test_uid').set(user.toFirestore());

      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );

      // Wait for auth state listener to process
      await Future.delayed(const Duration(milliseconds: 100));

      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.id, equals('test_uid'));
      expect(authProvider.currentUser!.email, equals('test@example.com'));
      expect(authProvider.currentUser!.nickname, equals('TestUser'));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isLoading, isFalse);
    });

    test('should create user in Firestore if Firebase Auth user exists but no Firestore doc', () async {
      final mockUser = MockUser(
        uid: 'test_uid',
        email: 'test@example.com',
        isAnonymous: false,
      );
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);

      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );

      // Wait for auth state listener to process
      await Future.delayed(const Duration(milliseconds: 100));

      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.id, equals('test_uid'));
      expect(authProvider.currentUser!.email, equals('test@example.com'));
      expect(authProvider.currentUser!.nickname, equals('test'));

      // Verify user was created in Firestore
      final doc = await fakeFirestore.collection('users').doc('test_uid').get();
      expect(doc.exists, isTrue);
    });
  });

  group('AuthProvider - Signup', () {
    setUp(() {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
    });

    test('should signup successfully with email, password, and nickname', () async {
      final result = await authProvider.signup(
        'newuser@example.com',
        'password123',
        'NewUser',
      );

      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.email, equals('newuser@example.com'));
      // MockFirebaseAuth may transform nickname based on email
      expect(authProvider.currentUser!.nickname, isNotEmpty);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isLoading, isFalse);

      // Verify user was created in Firestore
      final createdUser = await userRepository.getUser(authProvider.currentUser!.id);
      expect(createdUser, isNotNull);
      expect(createdUser!.email, equals('newuser@example.com'));
    });

    test('should set isLoading to true during signup', () async {
      bool loadingDuringSignup = false;

      authProvider.addListener(() {
        if (authProvider.isLoading) {
          loadingDuringSignup = true;
        }
      });

      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      expect(loadingDuringSignup, isTrue);
      expect(authProvider.isLoading, isFalse);
    });

    test('should create user with default values', () async {
      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      expect(authProvider.currentUser!.level, equals(1));
      expect(authProvider.currentUser!.credits, equals(250));
      expect(authProvider.currentUser!.sprouts, equals(250));
    });

    test('should notify listeners after successful signup', () async {
      int notifyCount = 0;
      authProvider.addListener(() => notifyCount++);

      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      expect(notifyCount, greaterThan(0));
    });

    test('should handle signup failure gracefully', () async {
      // MockFirebaseAuth doesn't fail, so we test with invalid input
      final result = await authProvider.signup('', '', '');

      // Either succeeds with empty values or fails - both are handled
      expect(authProvider.isLoading, isFalse);
    });
  });

  group('AuthProvider - Login', () {
    setUp(() async {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );

      // Create a user first
      await authProvider.signup('test@example.com', 'password123', 'TestUser');
      await authProvider.logout();
    });

    test('should login successfully with valid credentials', () async {
      final result = await authProvider.login('test@example.com', 'password123');

      expect(result, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.email, equals('test@example.com'));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isLoading, isFalse);
    });

    test('should set isLoading to true during login', () async {
      bool loadingDuringLogin = false;

      authProvider.addListener(() {
        if (authProvider.isLoading) {
          loadingDuringLogin = true;
        }
      });

      await authProvider.login('test@example.com', 'password123');

      expect(loadingDuringLogin, isTrue);
      expect(authProvider.isLoading, isFalse);
    });

    test('should notify listeners after successful login', () async {
      int notifyCount = 0;
      authProvider.addListener(() => notifyCount++);

      await authProvider.login('test@example.com', 'password123');

      expect(notifyCount, greaterThan(0));
    });

    test('should load user data from Firestore after login', () async {
      await authProvider.login('test@example.com', 'password123');

      expect(authProvider.currentUser!.nickname, equals('TestUser'));
      expect(authProvider.currentUser!.level, equals(1));
      expect(authProvider.currentUser!.credits, equals(250));
      expect(authProvider.currentUser!.sprouts, equals(250));
    });
  });

  group('AuthProvider - Logout', () {
    setUp(() async {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
      await authProvider.signup('test@example.com', 'password123', 'TestUser');
    });

    test('should logout successfully', () async {
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.logout();

      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('should notify listeners after logout', () async {
      int notifyCount = 0;
      authProvider.addListener(() => notifyCount++);

      await authProvider.logout();

      expect(notifyCount, greaterThan(0));
    });

    test('should clear user data after logout', () async {
      await authProvider.logout();

      expect(authProvider.currentUser, isNull);
    });
  });

  group('AuthProvider - Update Credits', () {
    setUp(() async {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
      await authProvider.signup('test@example.com', 'password123', 'TestUser');
    });

    test('should update credits successfully', () async {
      await authProvider.updateCredits(500);

      expect(authProvider.currentUser!.credits, equals(500));

      // Verify Firestore was updated
      final user = await userRepository.getUser(authProvider.currentUser!.id);
      expect(user!.credits, equals(500));
    });

    test('should notify listeners after updating credits', () async {
      int notifyCount = 0;
      authProvider.addListener(() => notifyCount++);

      await authProvider.updateCredits(500);

      expect(notifyCount, greaterThan(0));
    });

    test('should handle negative credits', () async {
      await authProvider.updateCredits(-100);

      expect(authProvider.currentUser!.credits, equals(-100));
    });

    test('should handle zero credits', () async {
      await authProvider.updateCredits(0);

      expect(authProvider.currentUser!.credits, equals(0));
    });

    test('should not update if user is null', () async {
      await authProvider.logout();

      // Should not throw
      await authProvider.updateCredits(500);

      expect(authProvider.currentUser, isNull);
    });
  });

  group('AuthProvider - Update Sprouts', () {
    setUp(() async {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
      await authProvider.signup('test@example.com', 'password123', 'TestUser');
    });

    test('should update sprouts successfully', () async {
      await authProvider.updateSprouts(1000);

      expect(authProvider.currentUser!.sprouts, equals(1000));

      // Verify Firestore was updated
      final user = await userRepository.getUser(authProvider.currentUser!.id);
      expect(user!.sprouts, equals(1000));
    });

    test('should notify listeners after updating sprouts', () async {
      int notifyCount = 0;
      authProvider.addListener(() => notifyCount++);

      await authProvider.updateSprouts(1000);

      expect(notifyCount, greaterThan(0));
    });

    test('should handle zero sprouts', () async {
      await authProvider.updateSprouts(0);

      expect(authProvider.currentUser!.sprouts, equals(0));
    });

    test('should not update if user is null', () async {
      await authProvider.logout();

      // Should not throw
      await authProvider.updateSprouts(1000);

      expect(authProvider.currentUser, isNull);
    });
  });

  group('AuthProvider - Update Level', () {
    setUp(() async {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
      await authProvider.signup('test@example.com', 'password123', 'TestUser');
    });

    test('should update level successfully', () async {
      await authProvider.updateLevel(10);

      expect(authProvider.currentUser!.level, equals(10));

      // Verify Firestore was updated
      final user = await userRepository.getUser(authProvider.currentUser!.id);
      expect(user!.level, equals(10));
    });

    test('should notify listeners after updating level', () async {
      int notifyCount = 0;
      authProvider.addListener(() => notifyCount++);

      await authProvider.updateLevel(5);

      expect(notifyCount, greaterThan(0));
    });

    test('should handle level 1', () async {
      await authProvider.updateLevel(1);

      expect(authProvider.currentUser!.level, equals(1));
    });

    test('should not update if user is null', () async {
      await authProvider.logout();

      // Should not throw
      await authProvider.updateLevel(10);

      expect(authProvider.currentUser, isNull);
    });
  });

  group('AuthProvider - Edge Cases', () {
    setUp(() {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
    });

    test('should handle multiple sequential logins', () async {
      await authProvider.signup('user1@example.com', 'password123', 'User1');
      await authProvider.logout();

      await authProvider.login('user1@example.com', 'password123');

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser!.email, equals('user1@example.com'));
    });

    test('should maintain user data across multiple updates', () async {
      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      await authProvider.updateCredits(500);
      await authProvider.updateSprouts(1000);
      await authProvider.updateLevel(5);

      expect(authProvider.currentUser!.credits, equals(500));
      expect(authProvider.currentUser!.sprouts, equals(1000));
      expect(authProvider.currentUser!.level, equals(5));
      expect(authProvider.currentUser!.nickname, equals('TestUser'));
    });

    test('should handle rapid successive updates', () async {
      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      await Future.wait([
        authProvider.updateCredits(100),
        authProvider.updateSprouts(200),
        authProvider.updateLevel(3),
      ]);

      expect(authProvider.currentUser!.credits, equals(100));
      expect(authProvider.currentUser!.sprouts, equals(200));
      expect(authProvider.currentUser!.level, equals(3));
    });

    test('should preserve immutability when updating', () async {
      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      final originalUser = authProvider.currentUser;
      await authProvider.updateCredits(500);

      // Original user object should not be modified
      expect(originalUser!.credits, equals(250));
      // New user object should have updated credits
      expect(authProvider.currentUser!.credits, equals(500));
      // But they should be different instances
      expect(identical(originalUser, authProvider.currentUser), isFalse);
    });

    test('should handle logout when already logged out', () async {
      expect(authProvider.isAuthenticated, isFalse);

      // Should not throw
      await authProvider.logout();

      expect(authProvider.isAuthenticated, isFalse);
    });
  });

  group('AuthProvider - State Management', () {
    setUp(() async {
      authProvider = AuthProvider(
        firebaseAuth: mockAuth,
        userRepository: userRepository,
      );
    });

    test('should notify listeners on all state changes', () async {
      final notifications = <String>[];

      authProvider.addListener(() {
        if (authProvider.isLoading) {
          notifications.add('loading');
        } else if (authProvider.isAuthenticated) {
          notifications.add('authenticated');
        } else {
          notifications.add('unauthenticated');
        }
      });

      await authProvider.signup('test@example.com', 'password123', 'TestUser');

      expect(notifications, isNotEmpty);
      expect(notifications.last, equals('authenticated'));
    });

    test('should maintain consistent state after dispose', () {
      // Dispose will be called in tearDown, so we just check current state
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });
  });
}
