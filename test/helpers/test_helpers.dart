import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moong_flutter/providers/auth_provider.dart';
import 'package:moong_flutter/providers/moong_provider.dart';
import 'package:moong_flutter/models/user.dart';

// TODO(Phase 8): Remove SQLite test helpers, replace with Firestore mocks
// These functions are no longer usable after SQLite removal

/// Create a test user with sensible defaults.
User createTestUser({
  String id = 'test_user',
  String nickname = 'TestUser',
  int level = 1,
  int credits = 250,
  int sprouts = 250,
}) {
  return User(
    id: id,
    nickname: nickname,
    level: level,
    credits: credits,
    sprouts: sprouts,
  );
}

/// Wrap a widget with required providers for widget testing.
///
/// TODO(Phase 8): Update to use Firebase Auth mocks and Firestore mocks
/// after Firebase migration is complete. For now, providers cannot
/// be instantiated without Firestore repository dependencies.
Widget wrapWithProviders(
  Widget child, {
  AuthProvider? authProvider,
  MoongProvider? moongProvider,
  List<ChangeNotifierProvider>? additionalProviders,
}) {
  final providers = <ChangeNotifierProvider>[
    // TODO: Uncomment after Phase 8 - Firebase Auth & Firestore mocks
    // ChangeNotifierProvider<AuthProvider>(
    //   create: (_) => authProvider ?? AuthProvider(
    //     firebaseAuth: MockFirebaseAuth(),
    //     userRepository: MockUserRepository(),
    //   ),
    // ),
    // ChangeNotifierProvider<MoongProvider>(
    //   create: (_) => moongProvider ?? MoongProvider(
    //     moongRepository: MockMoongRepository(),
    //   ),
    // ),
    ...?additionalProviders,
  ];

  return MultiProvider(
    providers: providers,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Wrap a widget with minimal MaterialApp for basic widget testing.
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(home: child);
}
