# Web Platform Notes

## 🌐 웹 플랫폼 제한사항

Moong 앱은 현재 **웹 플랫폼에서 제한적으로 지원**됩니다.

---

## ⚠️ 현재 상태

### SQLite 지원 불가
웹 플랫폼에서는 SQLite 데이터베이스를 사용할 수 없습니다.

**에러 메시지**:
```
UnsupportedError: SQLite is not supported on web platform.
Data persistence on web requires alternative storage solution.
```

### 영향받는 기능
- ✅ **UI 표시**: 정상 동작 (로그인 화면, Moong 선택 등)
- ❌ **데이터 저장**: 불가 (SQLite 미지원)
- ❌ **데이터 로드**: 불가 (데이터베이스 접근 불가)
- ✅ **메모리 내 상태**: 정상 동작 (Provider 상태 관리)

---

## 🎯 권장 플랫폼

### 완전 지원 플랫폼 ✅
다음 플랫폼에서는 모든 기능이 정상 작동합니다:

1. **Android** (API 21+)
   - Native SQLite 지원
   - 완전한 데이터 영속성
   
2. **iOS** (iOS 12.0+)
   - Native SQLite 지원
   - 완전한 데이터 영속성

3. **macOS** (10.15+)
   - sqflite_common_ffi 사용
   - 완전한 데이터 영속성

4. **Windows** (Windows 10+)
   - sqflite_common_ffi 사용
   - 완전한 데이터 영속성

5. **Linux** (Ubuntu 20.04+)
   - sqflite_common_ffi 사용
   - 완전한 데이터 영속성

---

## 🔧 웹 플랫폼 대안 (향후 구현)

### Option 1: SharedPreferences (간단한 데이터)
```dart
// 장점: 간단한 키-값 저장
// 단점: 복잡한 쿼리 불가, 대용량 데이터 부적합

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUser(User user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_json', jsonEncode(user.toJson()));
}
```

### Option 2: IndexedDB (브라우저 DB)
```dart
// 장점: 웹 브라우저 네이티브 DB, 대용량 데이터 지원
// 단점: 직접 구현 필요, SQL 쿼리 불가

import 'package:idb_shim/idb_browser.dart';

Future<void> setupIndexedDB() async {
  final idbFactory = getIdbFactory()!;
  final db = await idbFactory.open('moong_db', version: 1);
  // ObjectStore 생성 및 데이터 저장
}
```

### Option 3: Hive (NoSQL 데이터베이스)
```dart
// 장점: 크로스 플랫폼, 빠른 성능
// 단점: SQL 쿼리 불가, 스키마 변경 제한적

import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox<User>('users');
  await Hive.openBox<Moong>('moongs');
}
```

### Option 4: Firebase Firestore (클라우드 DB)
```dart
// 장점: 실시간 동기화, 백엔드 불필요
// 단점: 인터넷 연결 필요, 유료

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUser(User user) async {
  await FirebaseFirestore.instance
    .collection('users')
    .doc(user.id)
    .set(user.toJson());
}
```

---

## 📝 구현 가이드 (향후)

### 1. 플랫폼별 Storage Provider 패턴

```dart
// lib/storage/storage_provider.dart
abstract class StorageProvider {
  Future<void> saveUser(User user);
  Future<User?> getUser(String id);
  Future<void> deleteUser(String id);
}

// lib/storage/sqlite_storage.dart
class SqliteStorage implements StorageProvider {
  // Android, iOS, Desktop용
  @override
  Future<void> saveUser(User user) async {
    final dao = UserDao();
    await dao.insertUser(user);
  }
}

// lib/storage/web_storage.dart
class WebStorage implements StorageProvider {
  // 웹용 (IndexedDB 또는 SharedPreferences)
  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }
}

// lib/storage/storage_factory.dart
StorageProvider getStorageProvider() {
  if (kIsWeb) {
    return WebStorage();
  } else {
    return SqliteStorage();
  }
}
```

### 2. Provider 수정

```dart
class AuthProvider with ChangeNotifier {
  final StorageProvider _storage = getStorageProvider();
  
  Future<void> login(String nickname) async {
    final user = User(id: uuid.v4(), nickname: nickname);
    await _storage.saveUser(user);
    _currentUser = user;
    notifyListeners();
  }
}
```

---

## 🚀 현재 실행 방법

### 웹에서 테스트 (UI만)
```bash
# 웹 브라우저에서 실행 (데이터 저장 불가)
flutter run -d chrome

# 경고: 데이터베이스 에러 발생
# 하지만 UI는 정상 표시됨
```

### 완전한 기능 테스트
```bash
# Android 에뮬레이터
flutter run -d <android-emulator-id>

# iOS 시뮬레이터
flutter run -d <ios-simulator-id>

# macOS 데스크톱
flutter run -d macos

# Windows 데스크톱
flutter run -d windows

# Linux 데스크톱
flutter run -d linux
```

---

## 📊 플랫폼별 기능 비교

| 기능 | Android | iOS | macOS | Windows | Linux | **Web** |
|------|---------|-----|-------|---------|-------|---------|
| UI 렌더링 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| SQLite | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| 데이터 영속성 | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Provider 상태 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 이미지 캐싱 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 🔍 문제 해결

### 웹에서 데이터베이스 에러 발생 시

**증상**:
```
Bad state: databaseFactory not initialized
UnsupportedError: SQLite is not supported on web platform
```

**해결책**:
1. **Option A**: 다른 플랫폼 사용 (권장)
   ```bash
   flutter run -d macos
   flutter run -d chrome  # Android 에뮬레이터
   ```

2. **Option B**: 웹 전용 Storage 구현 (향후)
   - IndexedDB 또는 SharedPreferences 사용
   - Storage Provider 패턴 구현

3. **Option C**: 클라우드 DB 사용
   - Firebase Firestore
   - Supabase
   - AWS Amplify

---

## 📚 참고 자료

### 웹 Storage 관련
- [IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [SharedPreferences (Flutter)](https://pub.dev/packages/shared_preferences)
- [Hive (NoSQL)](https://pub.dev/packages/hive)
- [idb_shim (IndexedDB wrapper)](https://pub.dev/packages/idb_shim)

### SQLite 대안
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Supabase](https://supabase.com/docs)
- [PocketBase](https://pocketbase.io/)

---

## ✅ 권장사항

### 프로덕션 배포
1. **모바일 앱 우선**: Android/iOS용 APK/IPA 빌드
2. **데스크톱 앱**: macOS/Windows/Linux 실행 파일
3. **웹 앱**: UI 데모용으로만 사용 (데이터 저장 불가)

### 웹 지원 추가 시
1. Storage Provider 패턴 구현
2. IndexedDB 또는 Hive 통합
3. 또는 Firebase Firestore 연동
4. 플랫폼별 조건부 컴파일

---

**작성일**: 2026-02-03  
**버전**: 1.0  
**상태**: 웹 플랫폼 제한적 지원 (UI만)  
**권장 플랫폼**: Android, iOS, macOS, Windows, Linux
