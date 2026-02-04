# Moong App Playbook

## 📘 운영 가이드

이 문서는 Moong 앱의 개발, 배포, 운영, 트러블슈팅을 위한 실무 가이드입니다.

---

## 🚀 빠른 시작

### 1. 환경 요구사항

#### 필수 소프트웨어
```bash
- Flutter SDK: 3.7.2 이상
- Dart SDK: 3.7.2 이상
- Git: 2.0 이상
```

#### 플랫폼별 추가 요구사항
```bash
# iOS/macOS
- Xcode 15.0+ (macOS만 해당)
- CocoaPods

# Android
- Android Studio
- Android SDK 21+

# 웹
- Chrome 또는 Edge 브라우저

# 데스크톱 (Windows/Linux)
- Visual Studio 2022 (Windows)
- GCC/Clang (Linux)
```

### 2. 프로젝트 설정

```bash
# 1. 저장소 클론
git clone <repository-url>
cd hello_flutter

# 2. 의존성 설치
flutter pub get

# 3. 코드 분석
flutter analyze

# 4. 앱 실행 (개발 모드)
flutter run

# 특정 디바이스 지정
flutter run -d chrome        # 웹
flutter run -d macos         # macOS
flutter run -d <device-id>   # 연결된 디바이스
```

---

## 🔧 개발 환경 설정

### IDE 설정

#### VS Code
```json
// .vscode/settings.json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": false
}
```

#### Android Studio / IntelliJ
```
Settings → Languages & Frameworks → Flutter
- Flutter SDK path: /path/to/flutter
- Enable Hot Reload: ✓
- Format code on save: ✓
```

### 데이터베이스 관리

#### SQLite 데이터베이스 위치
```bash
# Android
/data/data/com.example.hello_flutter/databases/moong.db

# iOS
~/Library/Developer/CoreSimulator/Devices/<UUID>/data/Containers/Data/Application/<UUID>/Documents/moong.db

# macOS
~/Library/Containers/com.example.helloFlutter/Data/Library/Application Support/moong.db

# Windows
C:\Users\<Username>\AppData\Roaming\com.example\hello_flutter\moong.db

# Linux
~/.local/share/hello_flutter/moong.db

# Web
IndexedDB (브라우저 개발자 도구에서 확인)
```

#### 데이터베이스 초기화
```bash
# 앱 데이터 삭제 (Android)
adb shell pm clear com.example.hello_flutter

# 앱 데이터 삭제 (iOS Simulator)
xcrun simctl erase all

# 수동 DB 삭제
rm -rf <database-path>/moong.db
```

---

## 📦 빌드 & 배포

### Android 빌드

#### Debug APK
```bash
flutter build apk --debug
# 출력: build/app/outputs/flutter-apk/app-debug.apk
```

#### Release APK
```bash
flutter build apk --release
# 출력: build/app/outputs/flutter-apk/app-release.apk
```

#### App Bundle (Google Play)
```bash
flutter build appbundle --release
# 출력: build/app/outputs/bundle/release/app-release.aab
```

#### 서명 설정 (Release)
```properties
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore.jks>
```

### iOS 빌드

#### Simulator
```bash
flutter build ios --simulator
```

#### Device (Release)
```bash
flutter build ios --release
# Xcode에서 Archive → Distribute
```

#### Provisioning Profile 설정
```
Xcode → Signing & Capabilities
- Team: 선택
- Bundle Identifier: com.example.helloFlutter
- Provisioning Profile: 자동/수동 선택
```

### 웹 빌드

#### 개발 빌드
```bash
flutter run -d chrome
```

#### 프로덕션 빌드
```bash
flutter build web --release
# 출력: build/web/
```

#### 호스팅 (Firebase Hosting 예시)
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# 프로젝트 초기화
firebase init hosting

# 배포
firebase deploy --only hosting
```

### 데스크톱 빌드

#### macOS
```bash
flutter build macos --release
# 출력: build/macos/Build/Products/Release/hello_flutter.app
```

#### Windows
```bash
flutter build windows --release
# 출력: build\windows\runner\Release\
```

#### Linux
```bash
flutter build linux --release
# 출력: build/linux/x64/release/bundle/
```

---

## 🧪 테스트

### 단위 테스트
```bash
# 전체 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/database_test.dart

# 커버리지 리포트 생성
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 통합 테스트
```bash
flutter test integration_test/integration_flow_test.dart
```

### 위젯 테스트 (향후)
```bash
flutter test test/widget_test.dart
```

---

## 🐛 트러블슈팅

### 일반적인 문제

#### 1. Provider not found
**증상**: `ProviderNotFoundException: Error: Could not find the correct Provider`

**원인**: Widget 트리에서 Provider보다 상위에서 Provider를 조회하려고 함

**해결**:
```dart
// ❌ 잘못된 예
class MyApp extends StatelessWidget {
  Widget build(context) {
    final auth = Provider.of<AuthProvider>(context); // 에러!
    return MultiProvider(...);
  }
}

// ✅ 올바른 예
class MyApp extends StatelessWidget {
  Widget build(context) {
    return MultiProvider(
      providers: [...],
      child: Builder(
        builder: (context) {
          final auth = Provider.of<AuthProvider>(context); // OK
          return MaterialApp(...);
        },
      ),
    );
  }
}
```

#### 2. Database locked
**증상**: `DatabaseException: database is locked`

**원인**: 동시에 여러 트랜잭션이 실행됨

**해결**:
```dart
// Batch 작업 사용
final batch = db.batch();
batch.insert('users', user.toMap());
batch.insert('moongs', moong.toMap());
await batch.commit(noResult: true);

// 또는 transaction 사용
await db.transaction((txn) async {
  await txn.insert('users', user.toMap());
  await txn.insert('moongs', moong.toMap());
});
```

#### 3. Flutter pub get 실패
**증상**: `version solving failed`

**해결**:
```bash
# 캐시 클리어
flutter pub cache repair

# 의존성 재설치
rm -rf pubspec.lock
rm -rf .flutter-plugins
rm -rf .packages
flutter clean
flutter pub get
```

#### 4. Hot Reload 작동 안 함
**증상**: 코드 변경이 반영되지 않음

**해결**:
```bash
# Hot Restart 사용
r (콘솔에서)

# 또는 Full Restart
R (콘솔에서)

# 또는 앱 재실행
flutter run
```

#### 5. 웹에서 SQLite 오류
**증상**: `databaseFactory is not initialized`

**원인**: 웹 환경에서 sqflite_common_ffi 초기화 누락

**해결**:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(MyApp());
}
```

---

## 📊 모니터링 & 로깅

### 로그 레벨

#### 개발 환경
```dart
// Debug 로그 활성화
debugPrint('User logged in: ${user.nickname}');
```

#### 프로덕션 환경
```dart
// 에러만 로깅
try {
  await dao.insertUser(user);
} catch (e, stackTrace) {
  // 에러 리포팅 서비스 연동 (향후)
  // Sentry.captureException(e, stackTrace: stackTrace);
  debugPrint('Error: $e');
}
```

### 성능 모니터링 (향후)

```dart
// Firebase Performance Monitoring
final trace = FirebasePerformance.instance.newTrace('quest_completion');
await trace.start();
// ... 작업 수행
await trace.stop();
```

---

## 🔒 보안 체크리스트

### 배포 전 확인사항

- [ ] 디버그 로그 제거 (민감 정보)
- [ ] API 키 환경 변수로 관리
- [ ] ProGuard/R8 활성화 (Android)
- [ ] Code obfuscation 적용
- [ ] SSL Pinning 적용 (향후 서버 연동 시)
- [ ] 데이터베이스 암호화 고려 (민감 정보 시)

### Android 보안
```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### iOS 보안
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## 📈 성능 최적화

### 앱 크기 최적화

```bash
# 앱 크기 분석
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# 불필요한 리소스 제거
flutter clean
flutter pub get
flutter build apk --release --shrink
```

### 빌드 속도 개선

```bash
# Gradle Daemon 활성화 (Android)
echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties

# Build cache 사용
flutter build apk --build-shared-library
```

### 런타임 성능

```dart
// 이미지 캐싱
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 300, // 메모리 효율
  memCacheHeight: 300,
);

// ListView 최적화
ListView.builder(
  itemCount: items.length,
  cacheExtent: 100.0, // 프리로딩
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

---

## 🔄 CI/CD 설정 (향후)

### GitHub Actions 예시

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.7.2'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
```

---

## 📱 디바이스별 테스트 매트릭스

### Android
- **최소**: Android 5.0 (API 21)
- **권장**: Android 8.0 (API 26) 이상
- **테스트 기기**: Pixel 5, Samsung Galaxy S21, 저사양 디바이스

### iOS
- **최소**: iOS 12.0
- **권장**: iOS 14.0 이상
- **테스트 기기**: iPhone SE, iPhone 13, iPad Air

### 웹
- **브라우저**: Chrome 90+, Safari 14+, Firefox 88+, Edge 90+
- **해상도**: 1280x720 ~ 1920x1080

### 데스크톱
- **macOS**: macOS 10.15 (Catalina) 이상
- **Windows**: Windows 10 (1903) 이상
- **Linux**: Ubuntu 20.04 이상

---

## 🛠️ 유용한 명령어 모음

### Flutter CLI
```bash
# 디바이스 목록
flutter devices

# 로그 확인
flutter logs

# 앱 재시작 (Hot Restart)
flutter run --hot

# 프로파일 모드 실행
flutter run --profile

# Release 모드 실행
flutter run --release

# 의존성 업데이트
flutter pub upgrade

# 의존성 버전 확인
flutter pub outdated

# 코드 생성 (향후 build_runner 사용 시)
flutter pub run build_runner build

# 앱 크기 분석
flutter build apk --analyze-size --target-platform android-arm64
```

### 데이터베이스 관리
```bash
# Android 디바이스에서 DB 추출
adb pull /data/data/com.example.hello_flutter/databases/moong.db ./moong.db

# SQLite CLI로 DB 확인
sqlite3 moong.db
.tables
.schema users
SELECT * FROM users;
.quit
```

### Git 워크플로우
```bash
# Feature 브랜치 생성
git checkout -b feature/new-feature

# 커밋
git add .
git commit -m "feat: add new feature"

# Push
git push origin feature/new-feature

# Merge (PR 후)
git checkout main
git pull origin main
git merge feature/new-feature
```

---

## 📞 지원 및 문의

### 개발팀 연락처
- **이메일**: dev@moongapp.com (예시)
- **슬랙**: #moong-dev
- **이슈 트래커**: GitHub Issues

### 참고 문서
- [Flutter 공식 문서](https://docs.flutter.dev)
- [Dart 공식 문서](https://dart.dev/guides)
- [Provider 패키지](https://pub.dev/packages/provider)
- [sqflite 패키지](https://pub.dev/packages/sqflite)

---

## 📝 체크리스트

### 개발 완료 체크리스트
- [ ] 모든 기능 테스트 통과
- [ ] 코드 리뷰 완료
- [ ] 문서 업데이트
- [ ] CHANGELOG 작성

### 배포 체크리스트
- [ ] 버전 번호 업데이트 (pubspec.yaml)
- [ ] Release Notes 작성
- [ ] 앱 스토어 스크린샷 준비
- [ ] 마케팅 자료 준비
- [ ] 베타 테스트 완료
- [ ] 프로덕션 빌드 생성
- [ ] 앱 스토어 제출

### 모니터링 체크리스트 (배포 후)
- [ ] 크래시 리포트 확인
- [ ] 사용자 피드백 모니터링
- [ ] 성능 메트릭 확인
- [ ] 데이터베이스 마이그레이션 성공 확인

---

**작성일**: 2026-02-03  
**버전**: 1.0  
**작성자**: Warp AI Agent  
**최종 업데이트**: 2026-02-03
