# 🛠️ Development Guide - Moong App

개발자를 위한 상세 가이드

## 📋 목차

1. [개발 환경 설정](#개발-환경-설정)
2. [코드 스타일 가이드](#코드-스타일-가이드)
3. [화면 추가 가이드](#화면-추가-가이드)
4. [상태 관리](#상태-관리)
5. [테스팅](#테스팅)
6. [빌드 & 배포](#빌드--배포)
7. [트러블슈팅](#트러블슈팅)

## 개발 환경 설정

### 1. Flutter SDK 설치

```bash
# macOS
brew install flutter

# 버전 확인
flutter --version
# Flutter 3.x.x 이상 필요

# 의존성 체크
flutter doctor
```

### 2. IDE 설정

#### VS Code 추천 확장
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Pubspec Assist

#### Android Studio
- Flutter Plugin
- Dart Plugin

### 3. 프로젝트 설정

```bash
# 클론 후
cd hello_flutter

# 의존성 설치
flutter pub get

# 코드 생성 (필요시)
flutter pub run build_runner build

# 분석 실행
flutter analyze

# 테스트 실행
flutter test
```

## 코드 스타일 가이드

### Dart 코딩 컨벤션

```dart
// 1. 네이밍 컨벤션
class MyClassName { }          // UpperCamelCase for classes
const myConstant = 42;         // lowerCamelCase for variables
void myFunction() { }          // lowerCamelCase for functions
enum MyEnum { valueOne }       // UpperCamelCase for enums

// 2. Import 순서
import 'dart:async';           // Dart SDK
import 'package:flutter/material.dart';  // Flutter
import 'package:provider/provider.dart'; // External packages
import '../models/user.dart';  // Internal imports

// 3. 주석
/// 공개 API에 대한 문서 주석
/// 
/// 더 상세한 설명...
class MyClass { }

// 구현 세부사항에 대한 주석
void _privateMethod() { }

// 4. const 사용
const SizedBox(height: 20)     // ✅ Good
SizedBox(height: 20)           // ❌ Avoid
```

### 위젯 구조 패턴

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // 1. 상태 변수
  bool _isLoading = false;
  
  // 2. Lifecycle 메서드
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    // 리소스 정리
    super.dispose();
  }
  
  // 3. 비즈니스 로직 메서드
  Future<void> _loadData() async {
    // ...
  }
  
  // 4. Build 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
  
  // 5. UI 빌더 메서드 (private)
  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    );
  }
  
  Widget _buildHeader() { }
  Widget _buildContent() { }
  Widget _buildFooter() { }
}
```

## 화면 추가 가이드

### 1. 새 화면 만들기

```bash
# 1. 파일 생성
touch lib/screens/my_new_screen.dart
```

```dart
// 2. 기본 템플릿
import 'package:flutter/material.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFA5D6A7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(child: _buildContent()),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(Icons.arrow_back, () => Navigator.pop(context)),
          const Text('제목', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(width: 60),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return Center(child: Text('내용'));
  }
  
  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(Icons.home, () {}),
          _buildIconButton(Icons.settings, () {}),
        ],
      ),
    );
  }
  
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }
}
```

### 2. 라우팅 등록

```dart
// lib/main.dart
import 'screens/my_new_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // 기존 라우트...
        '/my-new': (context) => const MyNewScreen(),
      },
    );
  }
}
```

### 3. 네비게이션 사용

```dart
// Push (새 화면으로 이동)
Navigator.pushNamed(context, '/my-new');

// Push with arguments
Navigator.pushNamed(
  context,
  '/my-new',
  arguments: {'id': '123'},
);

// Pop (이전 화면으로)
Navigator.pop(context);

// Replace (현재 화면 교체)
Navigator.pushReplacementNamed(context, '/my-new');

// Pop until (특정 화면까지 돌아가기)
Navigator.popUntil(context, ModalRoute.withName('/'));
```

## 상태 관리

### Provider 사용법

#### 1. Provider 생성

```dart
// lib/providers/my_provider.dart
import 'package:flutter/material.dart';

class MyProvider with ChangeNotifier {
  int _counter = 0;
  
  int get counter => _counter;
  
  void increment() {
    _counter++;
    notifyListeners();  // UI 업데이트 트리거
  }
  
  Future<void> loadData() async {
    // 비동기 작업
    await Future.delayed(Duration(seconds: 1));
    _counter = 100;
    notifyListeners();
  }
}
```

#### 2. Provider 등록

```dart
// lib/main.dart
import 'package:provider/provider.dart';
import 'providers/my_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyProvider()),
        // 다른 providers...
      ],
      child: MyApp(),
    ),
  );
}
```

#### 3. Provider 사용

```dart
// UI에서 사용
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Provider 가져오기 (listen: true - 자동 업데이트)
    final myProvider = Provider.of<MyProvider>(context);
    
    // 또는 Consumer 사용
    return Consumer<MyProvider>(
      builder: (context, myProvider, child) {
        return Text('Counter: ${myProvider.counter}');
      },
    );
    
    // 2. Provider 가져오기 (listen: false - 읽기 전용)
    final myProvider2 = Provider.of<MyProvider>(context, listen: false);
    myProvider2.increment();  // 메서드 호출만
  }
}
```

### 로컬 저장소 (SharedPreferences)

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  // 저장
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }
  
  // 읽기
  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  
  // 삭제
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
```

## 애니메이션 가이드

### 1. 기본 애니메이션

```dart
class AnimatedWidget extends StatefulWidget {
  @override
  State<AnimatedWidget> createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.4),  // 0.8 ~ 1.2
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );
  }
}
```

### 2. 페이드 인/아웃

```dart
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 500),
  child: MyWidget(),
)
```

### 3. 슬라이드 애니메이션

```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(1, 0),  // 오른쪽에서
    end: Offset.zero,            // 제자리로
  ).animate(_controller),
  child: MyWidget(),
)
```

## 테스팅

### Unit Test

```dart
// test/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson should create valid User', () {
      final json = {
        'id': '1',
        'username': 'test',
        'email': 'test@test.com',
        'level': 5,
      };
      
      final user = User.fromJson(json);
      
      expect(user.id, '1');
      expect(user.username, 'test');
      expect(user.level, 5);
    });
    
    test('User.toJson should return valid Map', () {
      final user = User(
        id: '1',
        username: 'test',
        email: 'test@test.com',
        level: 5,
      );
      
      final json = user.toJson();
      
      expect(json['id'], '1');
      expect(json['username'], 'test');
    });
  });
}
```

### Widget Test

```dart
// test/widgets/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen has username and password fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );
    
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });
}
```

## 빌드 & 배포

### 개발 빌드

```bash
# 디버그 모드
flutter run

# 특정 디바이스
flutter run -d chrome
flutter run -d <device-id>

# 핫 리로드
# 앱 실행 중 'r' 키
# 핫 리스타트: 'R' 키
```

### 프로덕션 빌드

```bash
# Android APK
flutter build apk --release
# 출력: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (Play Store)
flutter build appbundle --release
# 출력: build/app/outputs/bundle/release/app-release.aab

# iOS
flutter build ios --release
# Xcode에서 Archive 필요

# Web
flutter build web --release
# 출력: build/web/
```

### 버전 관리

```yaml
# pubspec.yaml
version: 1.0.0+1
# 형식: major.minor.patch+build

# 버전 업데이트
version: 1.0.1+2  # 패치 업데이트
version: 1.1.0+3  # 마이너 업데이트
version: 2.0.0+4  # 메이저 업데이트
```

## 트러블슈팅

### 자주 발생하는 문제

#### 1. Build 실패

```bash
# 캐시 정리
flutter clean
flutter pub get

# Podfile 문제 (iOS)
cd ios
pod deintegrate
pod install
cd ..
```

#### 2. Provider 에러

```
Error: Could not find the correct Provider
```

**해결책**:
```dart
// Provider가 위젯 트리 상위에 있는지 확인
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
  child: MyApp(),  // MyApp 내부에서 Provider 사용 가능
)
```

#### 3. Navigator 에러

```
Navigator operation requested with a context that does not include a Navigator
```

**해결책**:
```dart
// MaterialApp을 build 메서드에서 반환하거나
// Builder를 사용하여 올바른 context 사용
Builder(
  builder: (context) => ElevatedButton(
    onPressed: () => Navigator.pushNamed(context, '/home'),
    child: Text('Home'),
  ),
)
```

#### 4. Async 경고

```
Don't use BuildContext across async gaps
```

**해결책**:
```dart
Future<void> loadData() async {
  await someAsyncOperation();
  
  // context 사용 전 mounted 체크
  if (!mounted) return;
  Navigator.pop(context);
}
```

#### 5. 이미지 로딩 실패

```bash
# pubspec.yaml에 assets 등록 확인
flutter:
  assets:
    - assets/images/
    - assets/icons/

# 캐시 정리 후 재실행
flutter clean
flutter pub get
flutter run
```

### 디버깅 팁

```dart
// 1. print 사용
print('Value: $myVariable');

// 2. debugPrint (콘솔 출력 제한 없음)
debugPrint('Long text...');

// 3. log 사용 (구조화된 로깅)
import 'dart:developer' as developer;
developer.log('Message', name: 'MyApp', error: exception);

// 4. assert (디버그 모드에서만 체크)
assert(value != null, 'Value should not be null');

// 5. Flutter DevTools
// flutter run 실행 후 제공되는 URL로 접속
```

## 성능 최적화

### 1. const 사용

```dart
// ❌ Bad
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Title'),
      SizedBox(height: 20),
    ],
  );
}

// ✅ Good
Widget build(BuildContext context) {
  return Column(
    children: const [
      Text('Title'),
      SizedBox(height: 20),
    ],
  );
}
```

### 2. ListView.builder 사용

```dart
// ❌ Bad - 모든 아이템을 한번에 생성
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ Good - 필요한 만큼만 생성
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### 3. 불필요한 rebuild 방지

```dart
// Provider에서 listen: false 사용
final provider = Provider.of<MyProvider>(context, listen: false);
provider.doSomething();  // rebuild 없이 메서드만 호출
```

## Git 워크플로우

```bash
# 브랜치 전략
main          # 프로덕션 코드
develop       # 개발 중인 코드
feature/*     # 새 기능
bugfix/*      # 버그 수정

# 작업 흐름
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# 작업 후
git add .
git commit -m "feat: Add my feature"
git push origin feature/my-feature

# Pull Request 생성 및 리뷰
# 승인 후 develop에 merge
```

### Commit Message 컨벤션

```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅, 세미콜론 등
refactor: 코드 리팩토링
test: 테스트 코드
chore: 빌드 업무, 패키지 관리

예시:
feat: Add login screen
fix: Fix navigation bug in shop screen
docs: Update README with setup instructions
```

---

**Happy Coding! 🚀**
