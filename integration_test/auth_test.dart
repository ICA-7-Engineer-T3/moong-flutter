import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hello_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete splash to login flow', (tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle();

      // Splash screen 확인
      expect(find.text('Moong'), findsWidgets);
      expect(find.text('함께하기'), findsOneWidget);

      // "함께하기" 버튼 탭
      await tester.tap(find.text('함께하기'));
      await tester.pumpAndSettle();

      // 로그인 화면 확인
      expect(find.text('로그인'), findsAtLeastNWidgets(1));
      expect(find.text('닉네임'), findsOneWidget);
      expect(find.text('pW'), findsOneWidget);
    });

    testWidgets('Login with empty credentials shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 로그인 화면으로 이동
      await tester.tap(find.text('함께하기'));
      await tester.pumpAndSettle();

      // 빈 상태로 로그인 시도
      final loginButtons = find.text('로그인');
      await tester.tap(loginButtons.last);
      await tester.pumpAndSettle();

      // 에러 메시지 확인 (SnackBar)
      expect(find.text('닉네임과 비밀번호를 입력해주세요'), findsOneWidget);
    });

    testWidgets('Login with valid credentials navigates to moong selection',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 로그인 화면으로 이동
      await tester.tap(find.text('함께하기'));
      await tester.pumpAndSettle();

      // 닉네임과 비밀번호 입력
      await tester.enterText(find.byType(TextField).first, 'testuser');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.pumpAndSettle();

      // 로그인 버튼 클릭
      final loginButtons = find.text('로그인');
      await tester.tap(loginButtons.last);
      await tester.pumpAndSettle();

      // 뭉 선택 화면으로 이동 확인
      // Note: 실제 구현에 따라 조정 필요
      expect(find.text('Pet'), findsOneWidget);
    });

    testWidgets('Navigate to signup screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 로그인 화면으로 이동
      await tester.tap(find.text('함께하기'));
      await tester.pumpAndSettle();

      // 회원가입 버튼 클릭
      await tester.tap(find.text('회원가입'));
      await tester.pumpAndSettle();

      // 회원가입 화면 확인
      // Note: signup screen의 UI 요소에 따라 조정 필요
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });
  });

  group('Session Persistence Tests', () => {
        testWidgets('App remembers logged in user', (tester) async {
          // TODO: SharedPreferences 등을 mock하여 테스트
        })
      });
}
