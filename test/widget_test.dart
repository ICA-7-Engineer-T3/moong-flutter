import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moong_flutter/main.dart';
import 'package:moong_flutter/providers/auth_provider.dart';
import 'package:moong_flutter/providers/moong_provider.dart';

void main() {
  testWidgets('MyApp smoke test - app renders without crash', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 300));

    // The app should render the MaterialApp with routes
    expect(find.byType(MultiProvider), findsOneWidget);
  });

  testWidgets('MyApp initializes with AuthProvider and MoongProvider',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify providers are accessible in widget tree
    final context = tester.element(find.byType(MultiProvider));
    expect(Provider.of<AuthProvider>(context, listen: false), isNotNull);
    expect(Provider.of<MoongProvider>(context, listen: false), isNotNull);
  });
}
