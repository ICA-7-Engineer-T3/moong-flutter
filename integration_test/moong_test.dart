import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moong_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Moong Management Integration Tests', () {
    testWidgets('Select moong type and create new moong', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 로그인 플로우 스킵을 위한 직접 테스트
      // TODO: 로그인 후 뭉 선택 화면까지 네비게이션
    });

    testWidgets('View moong in garden', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // TODO: 정원 화면 테스트
    });

    testWidgets('Interact with moong - tap and animations', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // TODO: 뭉과 상호작용 테스트
    });

    testWidgets('Navigate between moong screens', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // TODO: Main -> Quest -> Food -> Settings 네비게이션
    });
  });

  group('Moong Growth Tests', () {
    testWidgets('Complete quest increases intimacy', (tester) async {
      // TODO: 퀘스트 완료 시 친밀도 증가 테스트
    });

    testWidgets('Feed moong increases level', (tester) async {
      // TODO: 음식 제공 시 레벨 업 테스트
    });
  });
}
