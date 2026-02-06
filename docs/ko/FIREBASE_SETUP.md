# Firebase 설정 가이드

**작성일**: 2026-02-06
**프로젝트**: Moong Flutter (AI 펫 동반자 앱)
**Firebase 프로젝트**: moong-736e9

---

## 목차

1. [Firebase 프로젝트 개요](#firebase-프로젝트-개요)
2. [초기 설정](#초기-설정)
3. [개발 환경 구성](#개발-환경-구성)
4. [Firebase 서비스 사용 현황](#firebase-서비스-사용-현황)
5. [환경별 설정](#환경별-설정)

---

## Firebase 프로젝트 개요

### 프로젝트 정보
- **프로젝트 ID**: `moong-736e9`
- **프로젝트 이름**: Moong
- **리전**: asia-northeast3 (서울)
- **요금제**: Spark (무료 플랜)

### 사용 중인 Firebase 서비스
- ✅ **Firebase Authentication** - 이메일/비밀번호 인증
- ✅ **Cloud Firestore** - NoSQL 데이터베이스
- ✅ **Firebase Hosting** (선택사항) - 웹 호스팅

### 지원 플랫폼
- ✅ Web (Chrome, Safari, Firefox)
- ✅ iOS (테스트 준비 완료)
- ✅ Android (테스트 준비 완료)

---

## 초기 설정

### 1. Firebase CLI 설치

```bash
# npm을 통한 설치
npm install -g firebase-tools

# 버전 확인
firebase --version
```

### 2. Firebase 로그인

```bash
firebase login
```

### 3. FlutterFire CLI 설치

```bash
# Flutter용 Firebase 설정 도구
dart pub global activate flutterfire_cli

# 버전 확인
flutterfire --version
```

### 4. Firebase 프로젝트 연결

```bash
# 프로젝트 루트에서 실행
cd /path/to/moong-flutter

# Firebase 프로젝트 선택 및 플랫폼 설정
flutterfire configure --project=moong-736e9

# 옵션 선택
# - iOS: ✅ 선택
# - Android: ✅ 선택
# - Web: ✅ 선택
# - macOS: ❌ 선택 안 함
```

**생성되는 파일:**
- `lib/firebase_options.dart` - 자동 생성된 Firebase 설정 파일
- `firebase.json` - Firebase CLI 메타데이터

---

## 개발 환경 구성

### 필수 의존성 (pubspec.yaml)

```yaml
dependencies:
  # Firebase Core
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.0
  cloud_firestore: ^6.0.0

  # 상태 관리
  provider: ^6.1.2

dev_dependencies:
  # 테스트용 Firebase 모킹
  firebase_auth_mocks: ^0.15.0
  fake_cloud_firestore: ^4.0.1
```

### Firebase 초기화 코드 (lib/main.dart)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestore 오프라인 캐싱 설정
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}
```

---

## Firebase 서비스 사용 현황

### 1. Firebase Authentication

**설정된 인증 방식:**
- ✅ 이메일/비밀번호

**제공 기능:**
- 회원가입 (signup)
- 로그인 (login)
- 로그아웃 (logout)
- 자동 세션 관리
- 사용자 UID 기반 데이터 격리

**사용 위치:**
- `lib/providers/auth_provider.dart`

**테스트 계정:**
```
이메일: hong@talkcrm24.com
비밀번호: (팀 내부 공유)
```

### 2. Cloud Firestore

**데이터베이스 모드:** Native Mode
**리전:** asia-northeast3 (서울)

**컬렉션 구조:**
```
/users/{uid}                    ← 사용자 루트 컬렉션
  /moongs/{moongId}             ← 펫 정보 (서브컬렉션)
  /quests/{questId}             ← 퀘스트 (서브컬렉션)
  /inventory/{inventoryId}      ← 인벤토리 (서브컬렉션)
  /chatMessages/{messageId}     ← 채팅 기록 (서브컬렉션)

/shopItems/{itemId}             ← 상점 카탈로그 (루트 컬렉션 - 공유)
```

**오프라인 지원:**
- ✅ 웹: 자동 캐싱 활성화
- ✅ 모바일: 자동 캐싱 활성화
- 캐시 크기: 무제한 (`CACHE_SIZE_UNLIMITED`)

**사용 위치:**
- `lib/repositories/firestore/` (6개 Repository 구현체)

---

## 환경별 설정

### 개발 환경 (Development)

**프로젝트:** moong-736e9
**용도:** 로컬 개발 및 테스트

**실행 방법:**
```bash
# Web (Chrome)
flutter run -d chrome

# iOS 시뮬레이터
flutter run -d iphone

# Android 에뮬레이터
flutter run -d emulator
```

### 프로덕션 환경 (Production)

**배포 전 체크리스트:**
- [ ] Firebase Security Rules 검토
- [ ] API 키 확인 (환경변수 사용)
- [ ] 테스트 데이터 제거
- [ ] 빌드 최적화 (`flutter build --release`)

**배포 명령:**
```bash
# Web 배포
flutter build web --release
firebase deploy --only hosting

# iOS 배포
flutter build ios --release

# Android 배포
flutter build apk --release
flutter build appbundle --release
```

---

## 보안 고려사항

### 1. API 키 관리

⚠️ **중요:** `lib/firebase_options.dart`는 Git에 커밋되지만, 여기에 포함된 API 키는 공개용입니다.

**보안이 필요한 작업:**
- Firebase Security Rules로 데이터 접근 제어
- Firebase Admin SDK 사용 시 Service Account 키는 `.gitignore`에 추가

### 2. Service Account 키

**위치:** `.claude/moong-736e9-firebase-adminsdk.json`
**상태:** `.gitignore`에 포함되어 Git 추적 제외됨

**⚠️ 절대 커밋하지 마세요:**
```gitignore
# Firebase Service Account Keys
*.json
*-firebase-adminsdk-*.json
.claude/
```

### 3. 테스트 데이터

**테스트 계정:**
- 프로덕션 배포 전 테스트 계정 제거
- 또는 별도의 Firebase 프로젝트 사용 권장

---

## 문제 해결 (Troubleshooting)

### Firebase 초기화 실패

**증상:**
```
[ERROR] Firebase initialization error: ...
```

**해결 방법:**
1. `firebase_options.dart` 파일 확인
2. FlutterFire CLI 재실행: `flutterfire configure`
3. 의존성 재설치: `flutter pub get`

### Firestore 권한 오류

**증상:**
```
[cloud_firestore/permission-denied] Missing or insufficient permissions
```

**해결 방법:**
1. Firebase Console → Firestore Database → Rules 확인
2. Security Rules 업데이트 필요 (FIREBASE_SECURITY.md 참고)

### 웹에서 Firebase 로딩 실패

**증상:**
```
Failed to load Firebase SDK
```

**해결 방법:**
1. `web/index.html` 확인
2. 캐시 클리어: `flutter clean && flutter pub get`
3. 브라우저 캐시 삭제 후 재시도

---

## 다음 문서

- 📘 [Firestore ERD 및 데이터 구조](./FIRESTORE_ERD.md)
- 🔒 [Firebase 보안 규칙](./FIREBASE_SECURITY.md)
- 👥 [Firebase 협업 가이드](./FIREBASE_COLLABORATION.md)

---

## 참고 자료

- [Firebase 공식 문서](https://firebase.google.com/docs)
- [FlutterFire 문서](https://firebase.flutter.dev)
- [Cloud Firestore 시작하기](https://firebase.google.com/docs/firestore/quickstart)
